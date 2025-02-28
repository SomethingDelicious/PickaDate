//
//  UserTest.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

//KTG(250222/09:56) : 테스트용 내용입니다. 수정 가능.

import SwiftUI
import FirebaseFirestore

struct UserTest: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var num: Int
}
