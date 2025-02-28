//
//  Group.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

struct Group: Identifiable, Codable {
    @DocumentID var id: String?
    var groupID: String         //그룹 이름
    var createdAt: Date         //그룹 생성 날짜
    var leaderId: String          //그룹 장 ID
    var members: [String]        //그룹 원 ID 목록
    
    // Firestore에서 가져올 때 사용될 빈 생성자
    init() {
        self.groupID = ""
        self.leaderId = ""
        self.members = []
        self.createdAt = Date()
    }
    
    // 앱에서 그룹 생성 시 사용될 생성자
    init(groupID: String, leaderId: String, members: [String]) {
        self.groupID = groupID
        self.leaderId = leaderId
        self.members = members
        self.createdAt = Date()
    }
}

