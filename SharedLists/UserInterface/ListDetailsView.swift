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

    @State var itemUnderEdit: String = ""
    @State private var isSharePresented: Bool = false

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

        .sheet(isPresented: $isSharePresented, onDismiss: {
//            print("Dismiss")
        }, content: {
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
