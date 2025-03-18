//
//  User.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct PDUser: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String           // 사용자 이메일
    var fullName: String        // 풀네임
    var userName: String        // 유저네임
    var registeredAt: Date      //가입 날짜
    var joinedGroups: [String]     //참여 그룹
    var userID: String {          // 유저 uid
        return id ?? ""
    }
}

