//
//  ListEntry.swift
//  SharedLists
//
//  Created by Vadim Zhuk on 05/11/2023.
//

import Foundation
import FirebaseFirestore

struct ListEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var text: String
    var numberOfItems: Int
    var items: [ListItem]
}

extension ListEntry: Equatable {}

struct ListItem: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var isCompleted: Bool
}

extension ListItem: Equatable {}
