//
//  ListEntriesView.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 05/11/2023.
//

import SwiftUI

struct ListEntriesView: View {
   
    @EnvironmentObject var storage: FirestoreService

    @Binding var listEntries: [ListEntryProtocol]

    @State var newListPopoverShown: Bool = false
    @State var addExternalListPopoverShown: Bool = false
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
                                storage.update(list: listEntry.wrappedValue)
                            }
                    } else {
                        Text(listEntry.title.wrappedValue)
                            .foregroundStyle(listEntry.wrappedValue is ExternalListEntry ? .red : .black)
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
                    guard let listId = listEntry.wrappedValue.id else { return }
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
                newListPopoverShown.toggle()
            }, label: {
                Image(systemName: "plus")
            })
            Button(action: {
                addExternalListPopoverShown.toggle()
            }, label: {
                Image(systemName: "square.and.arrow.down")
            })
        })
        .createNewListPopover("New list", isPresented: $newListPopoverShown)
        .addExternalListPopover("Add external list", isPresented: $addExternalListPopoverShown)
    }
}

#Preview {
    ListEntriesView(listEntries: .constant([ListEntry(id: UUID().uuidString, title: "List tiltle", text: "List body text", items: [])]))
}
