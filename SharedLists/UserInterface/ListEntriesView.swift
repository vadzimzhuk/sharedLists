//
//  ListEntriesView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 05/11/2023.
//

import SwiftUI

struct ListEntriesView: View {
   
    @EnvironmentObject var storage: FirestoreService

    @Binding var listEntries: [ListEntry]

    @State var newListPopOverShown: Bool = false
    @State var editingListId: String?

    @FocusState var listTitleFocus

    var body: some View {
        List($listEntries, id: \.id) { listEntry in
            HStack {
                NavigationLink{
                    ListDetailsView(listEntry: listEntry)
                } label: {
                    if listEntry.wrappedValue.id == editingListId {
                        TextField("List name", text: listEntry.title)
                            .focused($listTitleFocus)
                            .onSubmit {
                                editingListId = nil
                            }
                    } else {
                        Text(listEntry.title.wrappedValue)
                        Spacer()
                        Text(" \(listEntry.wrappedValue.numberOfItems)")
                    }
                }
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button(role: .none) {
                    editingListId = listEntry.wrappedValue.id
                    listTitleFocus = true
                } label: {
                    HStack {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                    }
                }
                .tint(.yellow)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    guard let listId = listEntry.id else { return }
                    storage.delete(listId: listId)
                } label: {
                    HStack {
                        Image(systemName: "trash")
                    }
                }
                .tint(.red)
            }
        }
        .listStyle(.plain)
        .toolbar(content: {
            Button(action: {
                newListPopOverShown.toggle()
            }, label: {
                Image(systemName: "plus")
            })
        })
        .createNewListPopover("New list", isPresented: $newListPopOverShown)
    }
}

#Preview {
    ListEntriesView(listEntries: .constant([ListEntry(id: UUID().uuidString, title: "List tiltle", text: "List body text", numberOfItems: 0, items: [])]))
}
