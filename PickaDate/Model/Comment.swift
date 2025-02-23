//
//  Comment.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var commentID: String
    var content: String
    var writer: String
    var createdAt: Date
}
