//
//  Comment.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    var id: String
    var content: String
    var author: String
    var createdAt: Date
}
