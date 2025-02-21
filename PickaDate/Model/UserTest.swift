//
//  User.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct UserTest: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var num: Int
}
