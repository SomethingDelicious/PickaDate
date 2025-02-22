//
//  User.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String          //사용자 ID
    var userPW: String          //사용자 PW (임시, 수정 예정)
    var registeredAt: Date      //가입 날짜
    var joinGroup: [String]     //참여 그룹
}

