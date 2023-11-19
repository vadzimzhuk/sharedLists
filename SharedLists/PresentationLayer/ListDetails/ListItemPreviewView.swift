//
//  ListItemPreviewView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 06/11/2023.
//

import SwiftUI

struct ListItemPreviewView: View {

    class Model: ObservableObject {
        let storage: FirestoreService = DIContainer.shared.resolve(FirestoreService.self)!
        
        var listId: String

        var listItem: ListItem //{
//            didSet {
//                storage.edit(item: listItem, in: listId)
//            }
//        }

        init(listId: String, listItem: ListItem) {
            self.listId = listId
            self.listItem = listItem
        }

        func removeItem() {
            storage.delete(itemId: listItem.id!, from: listId)
        }

        func onSubmit() {
            storage.edit(item: listItem, in: listId)
        }
    }

    @ObservedObject var model: Model

    @Binding var listItem: ListItem
    @Binding var itemUnderEdit: String
    @Binding var newItems: [ListItem]

    var createNextItemAction: (() -> Void)?

    @FocusState var textFieldFocus: Bool

    private var underEdit: Bool { itemUnderEdit == listItem.id }

    private func setEditable() {
        if let id = listItem.id { itemUnderEdit = id }
        textFieldFocus = true
    }

    private func setCompleted() {
        listItem.isCompleted.toggle()
        textFieldFocus = false
        itemUnderEdit = ""
//        model.onSubmit()
    }

    private func setFocusIfNeeded() {
        if (newItems.contains { $0.id == listItem.id }) {
            itemUnderEdit = listItem.id!
            textFieldFocus = true
        }
    }

    var body: some View {
        HStack {
            if underEdit {
                TextField("New item", text: $listItem.text)
                .focused($textFieldFocus)
                .foregroundStyle(listItem.isCompleted ? .gray.opacity(0.5) : .black)
                .onSubmit {
                    if listItem.text.isEmpty {
                        itemUnderEdit = ""
                        model.removeItem()
                    } else {
                        itemUnderEdit = ""
                        model.onSubmit()
                        createNextItemAction?()
                    }
                }
            } else {
                Text(listItem.text)
                    .foregroundStyle(listItem.isCompleted ? .gray.opacity(0.5) : .black)
                    .onTapGesture { setEditable() }
            }

            Spacer()

            Button {
                setCompleted()
            } label: {
                WrapperView {
                    Image(systemName: listItem.isCompleted ? "xmark.square" : "square")
                        .padding(5)
                }
            }
        }
        .onAppear {
            setFocusIfNeeded()
            withAnimation { newItems.removeAll { $0.id == listItem.id } }
        }
        .onDisappear {
            model.onSubmit()
        }
        .onChange(of: listItem) { oldValue, newValue in
            model.listItem = newValue
        }
    }
}

private var listItem = ListItem(text: "Milk", isCompleted: false)

#Preview {
    ListItemPreviewView(model: .init(listId: "", listItem: listItem), listItem: .constant(listItem), itemUnderEdit: .constant(""), newItems: .constant([]))
}
