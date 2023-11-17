//
//  StorageService.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 03/11/2023.
//

import Foundation
import FirebaseFirestore

protocol StorageService {
//    func getLists() -> [ListEntry]
    func create(list: ListEntryProtocol)
    func delete(listId: String)
    func update(list: ListEntryProtocol)
    func add(item: ListItem, to list: ListEntryProtocol)
    func edit(item: ListItem, in listId: String)
    func delete(item: ListItem, from list: ListEntryProtocol)
    func addExternalList(with id: String, of userId: String) async
}

class FirestoreService: StorageService, ObservableObject {

    let store: AppStateStore

    @Published var listEntries: [ListEntryProtocol] = []

    private var listsChangesListener: ListenerRegistration?
    private var externalListsListeners: [ListenerRegistration] = []

    private var userId: String {
        guard let userId = store.state.currentUser?.id else { return store.state.currentUser?.id ?? ""}

        return userId
    }

    private let db = Firestore.firestore()

    init(appStateStore: AppStateStore) {
        self.store = appStateStore
    }

    func userRef(userId: String) -> DocumentReference {
        db.collection("users").document(userId)
    }

    func userListsRef() -> CollectionReference {
        userRef(userId: userId).collection("listEntries")
    }

    func subscribeOnDataUpdates(user: String) {
        listsChangesListener?.remove()

        listsChangesListener = userRef(userId: user).collection("listEntries")
          .addSnapshotListener { [weak self] collectionSnapshot, error in
              guard let collectionSnapshot else { return }

              Task { [weak self] in
                  guard let self else { return }

                  let entries = await self.getSubCollection(query: collectionSnapshot)

                  await MainActor.run {
                      self.listEntries = entries
                  }
              }
          }
    }

    func subscribeOnUpdates<T: Decodable>(collection: CollectionReference, completionHandler: @escaping ([T]) -> Void) -> ListenerRegistration {
        return collection
          .addSnapshotListener { collectionSnapshot, error in
              guard let collectionSnapshot else { return }

              let listItems = collectionSnapshot.documents.compactMap {
                  try? $0.data(as: T.self)
              }

              completionHandler(listItems)
          }
    }

    func getSubCollection(query: QuerySnapshot) async -> [ListEntryProtocol] {
        // clean listeners
        externalListsListeners.forEach { registration in
            registration.remove()
        }

        var lists: [ListEntryProtocol] = []
        let documents = query.documents

        for document in documents {
            do {
                var list = try document.data(as: ListEntry.self)
                list.items = await getItems(for: list)
//                list.numberOfItems = list.items.count
                lists.append(list)
            } catch {
                print(error)
                
                if let externalList = document["extList"] as? DocumentReference {


                    if let listEntry = try? await externalList.getDocument(as: ListEntry.self) {
                        var externalListEntry = ExternalListEntry(path: externalList, list: listEntry)
                        externalListEntry.items = await getItems(for: externalListEntry)
                        let externalListEntryId = externalListEntry.id

                        let listener = self.subscribeOnUpdates(collection: externalList.collection("items")) { (items: [ListItem]) in

                            DispatchQueue.main.async {
                                if let index = (self.listEntries.firstIndex { list in
                                    list.id == externalListEntryId
                                }) {
                                    self.listEntries[index].items = items
                                }
                            }
                        }

                        externalListsListeners.append(listener)

                        lists.append(externalListEntry)
                    } else {
                        print(externalList)
                    }
                } else {
                    assertionFailure()
                }
            }
        }

        return lists
    }

    func getItems(for list: ListEntryProtocol) async -> [ListItem] {
        guard let listId = list.id else { return [] }

        if list is ListEntry {
            let collection = try? await userRef(userId: userId).collection("listEntries").document(listId).collection("items").getDocuments()

            let listItems = collection?.documents.compactMap {
                try? $0.data(as: ListItem.self)
            }

            return listItems ?? []
        } else if let list = list as? ExternalListEntry {
            let collection = try? await list.path.collection("items").getDocuments()

            let listItems = collection?.documents.compactMap {
                try? $0.data(as: ListItem.self)
            }

            return listItems ?? []

        }

        assertionFailure()
        return []
    }

//    func getLists() -> [ListEntry] {
//        var outputLists: [ListEntry] = []
//
//        let colRef = userEntriesRef()
//
//        colRef.getDocuments { documents, error in
//            guard let documents else { return }
//
//            let lists: [ListEntry] = documents.documents.map { ListEntry(id: $0.documentID, title: $0["title"] as! String, text: $0["text"] as! String, items: []/*$0["items"].map { ListItem(text: $0["text"] as! String, isCompleted: $0["isCompleted"] as! Bool)}*/)}
//            outputLists = lists
//        }
//
//        return outputLists
//    }

    func addExternalList(with id: String, of userId: String) async {
        let externalListRef = db.collection("users").document(userId).collection("listEntries").document(id)
        if let externalList = try? await externalListRef.getDocument(as: ListEntry.self) {
            let list = ExternalListEntry(path: externalListRef, list: externalList)
            // TODO: - check for duplicates
            create(list: list)
        } else {
            assertionFailure()
        }
    }

    func create(list: ListEntryProtocol) {
        if let list = list as? ListEntry {
            let newListRef = userListsRef().document()

            do {
                try newListRef.setData(from: list)
                newListRef.updateData(["path": newListRef.path])
            } catch {
                print(error)
            }
        } else if let list = list as? ExternalListEntry {
            let newListRef = userListsRef().document()

            newListRef.setData(["extList" : list.path])
        }
    }

    func delete(listId: String) {
        let itemRef = userListsRef().document(listId)
        itemRef.delete()
    }

    func update(list: ListEntryProtocol) {
        guard let listId = list.id else { assertionFailure(); return }

        if list is ListEntry {
            let listRef = userListsRef().document(listId)

            listRef.updateData(["title" : list.title,
                                "text" : list.text])
        } else if let list = list as? ExternalListEntry {
            let listRef = list.path

            listRef.updateData(["title" : list.title,
                                "text" : list.text])
        }
    }

    func add(item: ListItem, to list: ListEntryProtocol) {
        guard let listId = list.id else { assertionFailure(); return }

        if list is ListEntry {
            let newItemRef = userListsRef().document(listId).collection("items").document()

            do {
                try newItemRef.setData(from: item)

//                let noi = list.items.count + 1
//                userListsRef().document(listId).updateData(["numberOfItems" : noi])

            } catch {
                print(error)
            }
        } else if let list = list as? ExternalListEntry {
            let newItemRef = list.path.collection("items").document()

                do {
                    try newItemRef.setData(from: item)

//                    let noi = list.items.count + 1
//                    userListsRef().document(listId).updateData(["numberOfItems" : noi])

                } catch {
                    print(error)
                }
        }
    }

    func edit(item: ListItem, in listId: String) {
        guard let itemId = item.id else { assertionFailure(); return }

        let itemRef = userListsRef().document(listId).collection("items").document(itemId)

        itemRef.updateData(["text" : item.text,
                           "isCompleted" : item.isCompleted])
    }

    func delete(item: ListItem, from list: ListEntryProtocol) {
        guard let listId = list.id,
        let itemId = item.id else { assertionFailure(); return }

        let itemRef = userListsRef().document(listId).collection("items").document(itemId)
        itemRef.delete()

//        let noi = list.items.count - 1
//        userListsRef().document(listId).updateData(["numberOfItems" : noi])
    }
}
