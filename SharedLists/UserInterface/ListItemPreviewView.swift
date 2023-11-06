//
//  ListItemPreviewView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 06/11/2023.
//

import SwiftUI

struct ListItemPreviewView: View {

    class Model: ObservableObject {
        var listId: String
        var listItem: ListItem {
            didSet {
                DIContainer.shared.resolve(FirestoreService.self)!.edit(item: listItem, in: listId)
            }
        }

        init(listId: String, listItem: ListItem) {
            self.listId = listId
            self.listItem = listItem
        }
    }

    @ObservedObject var model: Model

    @Binding var listItem: ListItem

    var body: some View {
        HStack {
            TextField("New item", text: $listItem.text)


            Spacer()

            Button {
                listItem.isCompleted.toggle()
            } label: {
                Image(systemName: listItem.isCompleted ? "xmark.square" : "square")
            }
        }
        .onChange(of: listItem) { oldValue, newValue in
            model.listItem = newValue
        }
    }
}

//#Preview {
//    ListItemPreviewView(listItem: .constant(ListItem(text: "Milk", isCompleted: false)))
//}
