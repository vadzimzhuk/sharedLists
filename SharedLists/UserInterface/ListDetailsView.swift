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

    @Binding var listEntry: ListEntryProtocol

    @State var itemUnderEdit: String = ""

    @FocusState var newItemFocus

    var body: some View {
        List($listEntry.items, id: \.id) { listItem in
            ListItemPreviewView(model: .init(listId: listEntry.id ?? "", listItem: listItem.wrappedValue), listItem: listItem, itemUnderEdit: $itemUnderEdit)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive) {
                        storage.delete(item: listItem.wrappedValue, from: listEntry)
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                        }
                    }
                    .tint(.red)
                }
        }
        .navigationTitle(listEntry.title)
        .toolbar(content: {

            Button(action: {

            }, label: {
                Image(systemName: "square.and.arrow.up")
            })

            Button(action: {
                let listItem = ListItem(id: UUID().uuidString, text: "New item", isCompleted: false)
                storage.add(item: listItem, to: listEntry)
            }, label: {
                Image(systemName: "plus")
            })
        })
    }
}

#Preview {
    ListDetailsView(listEntry: .constant(ListEntry(title: "Shopping", text: "Shopping list", items: [
        ListItem(text: "Milk", isCompleted: false)
    ])))
}
