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
    var userID: String          //사용자 ID
    var email: String           // 사용자 이메일
    var userName: String        //사용자 이름(혹은 닉네임)
    var registeredAt: Date      //가입 날짜
    var joinedGroups: [String]     //참여 그룹
}

