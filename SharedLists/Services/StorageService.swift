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
    func create(list: ListEntry)
    func delete(listId: String)
    func update(list: ListEntry)
    func add(item: ListItem, to list: ListEntry)
    func edit(item: ListItem, in listId: String)
    func delete(item: ListItem, from list: ListEntry)
}

class FirestoreService: StorageService, ObservableObject {

    let store: AppStateStore

    @Published var listEntries: [ListEntry] = []

    private var listsChangesListener: ListenerRegistration?

    private var userId: String {
        guard let userId = store.state.currentUser?.id else { fatalError() }

        return userId
    }

    private let db = Firestore.firestore()

    init(appStateStore: AppStateStore) {
        self.store = appStateStore
    }

    func userRef(userId: String) -> DocumentReference {
        db.collection("users").document(userId)
    }

    func userEntriesRef() -> CollectionReference {
        userRef(userId: userId).collection("listEntries")
    }

    func subscribeOnDataUpdates(user: String) {
        listsChangesListener?.remove()

        listsChangesListener = userRef(userId: user).collection("listEntries")
          .addSnapshotListener { [weak self] collectionSnapshot, error in
              guard let collectionSnapshot else { return }

              Task { [weak self] in
                  guard let self else { return }

                  /*self.listEntries*/let entries = await self.getSubCollection(query: collectionSnapshot)

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

    func getSubCollection(query: QuerySnapshot) async -> [ListEntry] {
        var lists: [ListEntry] = []
        let documents = query.documents

        for document in documents {
            do {
                var list = try document.data(as: ListEntry.self)
                list.items = await getItems(for: list)
                list.numberOfItems = list.items.count
                lists.append(list)
            } catch {
                print(error)
            }
        }

        return lists
    }

    func getItems(for list: ListEntry) async -> [ListItem] {
        guard let listId = list.id else { return [] }

        let collection = try? await userRef(userId: userId).collection("listEntries").document(listId).collection("items").getDocuments()

        let listItems = collection?.documents.compactMap {
            try? $0.data(as: ListItem.self)
        }

        return listItems ?? []
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

    func create(list: ListEntry) {
        let newListRef = userEntriesRef().document()

        do {
            try newListRef.setData(from: list)
//            newListRef.updateData(["id" : FieldValue.delete()])
        } catch {
            print(error)
        }
    }

    func delete(listId: String) {
        let itemRef = userEntriesRef().document(listId)
        itemRef.delete()
    }

    func update(list: ListEntry) {
        guard let listId = list.id else { assertionFailure(); return }

        let listRef = userEntriesRef().document(listId)

        listRef.updateData(["title" : list.title,
                            "text" : list.text])
    }

    func add(item: ListItem, to list: ListEntry) {
        guard let listId = list.id else { assertionFailure(); return }

        let newItemRef = userEntriesRef().document(listId).collection("items").document()

        do {
            try newItemRef.setData(from: item)

            let noi = list.items.count + 1
            userEntriesRef().document(listId).updateData(["numberOfItems" : noi])

        } catch {
            print(error)
        }
    }

    func edit(item: ListItem, in listId: String) {
        guard let itemId = item.id else { assertionFailure(); return }

        let itemRef = userEntriesRef().document(listId).collection("items").document(itemId)

        itemRef.updateData(["text" : item.text,
                           "isCompleted" : item.isCompleted])
    }

    func delete(item: ListItem, from list: ListEntry) {
        guard let listId = list.id,
        let itemId = item.id else { assertionFailure(); return }

        let itemRef = userEntriesRef().document(listId).collection("items").document(itemId)
        itemRef.delete()

        let noi = list.items.count - 1
        userEntriesRef().document(listId).updateData(["numberOfItems" : noi])
    }
}
