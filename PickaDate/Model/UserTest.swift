//
//  User.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

//KTG(250222/09:56) : 테스트용 내용입니다. 수정 가능.

import SwiftUI
import FirebaseFirestore

struct PDUserTest: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var num: Int
}
