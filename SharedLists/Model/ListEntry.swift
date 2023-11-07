//
//  ListEntry.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 05/11/2023.
//

import Foundation
import FirebaseFirestore

protocol ListEntryProtocol {
    var id: String? { get set }
    var title: String { get set }
    var text: String { get set }
    var numberOfItems: Int { get }
    var items: [ListItem] { get set }
}

struct ListEntry: ListEntryProtocol, Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var text: String
    var numberOfItems: Int {
        items.count
    }
    var items: [ListItem]
}

extension ListEntry: Equatable {}

struct ListItem: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var isCompleted: Bool
}

extension ListItem: Equatable {}

struct ExternalListEntry: ListEntryProtocol, Identifiable, Codable {
    var id: String? {
        get {
            list.id
        }

        set {
            list.id = newValue
        }
    }

    var title: String {
        get {
            list.title
        }

        set {
            list.title = newValue
        }
    }

    var text: String {
        get {
            list.text
        }

        set {
            list.text = newValue
        }
    }

    var numberOfItems: Int {
        get {
            list.numberOfItems
        }
    }

    var items: [ListItem] {
        get {
            list.items
        }

        set {
            list.items = newValue
        }
    }

    let path: DocumentReference

    var list: ListEntry
}
