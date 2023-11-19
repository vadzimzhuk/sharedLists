//
//  ListDetailsView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 06/11/2023.
//

import SwiftUI

struct ListDetailsView: View {

    let storage: FirestoreService = {
        DIContainer.shared.resolve(FirestoreService.self)!
    }()

    @EnvironmentObject var store: AppStateStore

    @Binding var listEntry: ListEntryProtocol
    
    var listItems: [ListItem] {
        listEntry.items.sorted { $0.isCompleted && !$1.isCompleted }
    }

    @State var itemUnderEdit: String = ""
    @State private var isSharePresented: Bool = false
    @State var newItems: [ListItem] = []

    func createNewItem() {
        let listItem = ListItem(id: UUID().uuidString, text: "", isCompleted: false)
//        self.listEntry.items.append(listItem)
        storage.add(item: listItem, to: listEntry)
    }

    var body: some View {
        List($listEntry.items, id: \.id) { listItem in

            ListItemPreviewView(model: .init(listId: listEntry.id!, listItem: listItem.wrappedValue), listItem: listItem, itemUnderEdit: $itemUnderEdit, newItems: $newItems, createNextItemAction: {
                createNewItem()
            })
            .background((newItems.contains { $0.id == listItem.id }) ? Color.red : Color.white)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        storage.delete(itemId: listItem.wrappedValue.id!, from: listEntry.id!)
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                        }
                    }
                    .tint(.red)
                }
        }
        .listStyle(.plain)
        .onChange(of: listEntry.items, { oldValue, newValue in
            let change = newValue.difference(from: oldValue)

            change.insertions.forEach {
                switch $0 {
                    case .insert(_, let element, _):
                        newItems.append(element)
                    default:
                        return
                }
            }
            
            change.removals.forEach { removal in
                if case let .remove(_, element, _) = removal {
                    newItems.removeAll { $0.id == element.id }
                }
            }
        })
        .sheet(isPresented: $isSharePresented, onDismiss: {}, content: {
            ActivityViewController(activityItems: ["sharedlists://share?userid=\(store.state.currentUser?.id ?? "")&listid=\(listEntry.id ?? "")"])
        })
        .navigationTitle(listEntry.title)
        .toolbar(content: {

            Button(action: {
                isSharePresented = true
            }, label: {
                Image(systemName: "square.and.arrow.up")
            })

            Button(action: {
                if itemUnderEdit.isEmpty {
                    createNewItem()
//                    let listItem = ListItem(id: UUID().uuidString, text: "", isCompleted: false)
//                    storage.add(item: listItem, to: listEntry)
//                    listEntry.items.append(listItem)
                } else {
                    itemUnderEdit = ""
                    if listEntry.items.last?.text.isEmpty == true,
                       let id = listEntry.items.last?.id {
                        storage.delete(itemId: id, from: listEntry.id!)
                    }
                }
            }, label: {
                Image(systemName: itemUnderEdit.isEmpty ? "plus" : "tray.and.arrow.down")
            })
        })
    }
}

#Preview {
    ListDetailsView(listEntry: .constant(ListEntry(title: "Shopping", text: "Shopping list", items: [
        ListItem(text: "Milk", isCompleted: false)
    ])))
}

import UIKit
//import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {

    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}

}
