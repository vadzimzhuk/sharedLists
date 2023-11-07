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
    @Binding var itemUnderEdit: String

    @FocusState var textFieldFocus: Bool

    private var underEdit: Bool { itemUnderEdit == listItem.id }

    var body: some View {
        HStack {
            if underEdit {
                TextField("New item", text: $listItem.text)
                .focused($textFieldFocus)
                .foregroundStyle(listItem.isCompleted ? .gray.opacity(0.5) : .black)
            } else {
                Text(listItem.text)
                    .foregroundStyle(listItem.isCompleted ? .gray.opacity(0.5) : .black)
                    .onTapGesture {
                        guard let id = listItem.id else { return }
                        itemUnderEdit = id
                        textFieldFocus = true
                    }
            }

            Spacer()

            Button {
                listItem.isCompleted.toggle()
                textFieldFocus = false
                itemUnderEdit = ""
            } label: {
                WrapperView {
                    Image(systemName: listItem.isCompleted ? "xmark.square" : "square")
                        .padding(5)
                }
            }
        }
        .onChange(of: listItem) { oldValue, newValue in
            model.listItem = newValue
        }
    }
}

private var listItem = ListItem(text: "Milk", isCompleted: false)

#Preview {
    ListItemPreviewView(model: .init(listId: "", listItem: listItem), listItem: .constant(listItem), itemUnderEdit: .constant(""))
}
