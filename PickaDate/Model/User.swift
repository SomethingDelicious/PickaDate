//
//  User.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String          //사용자 ID
    var email: String           // 사용자 이메일
    var userName: String        //사용자 이름(혹은 닉네임)
    var userPW: String          //사용자 PW (임시, 수정 예정)
    var registeredAt: Date      //가입 날짜
    var joinedGroups: [String]     //참여 그룹

    
    // Firestore에서 가져올 때 사용될 빈 생성자
    init() {
        self.userID = ""
        self.email = ""
        self.userName = ""
        self.userPW = ""
        self.registeredAt = Date()
        self.joinedGroups = []

    }
    
    // 앱에서 사용자 생성 시 사용될 생성자
    init(userID: String, userName: String, email: String, userPW: String) {
        self.userID = userID
        self.email = email
        self.userName = userName
        self.userPW = userPW
        self.registeredAt = Date()
        self.joinedGroups = []

    }
}

