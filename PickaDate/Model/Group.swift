//
//  Group.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct PDGroup: Identifiable, Codable {
    @DocumentID var id: String?
    var groupID: String         //그룹 고유 id(동일한 그룹이름을 가질 경우 구분)
    var groupName: String       //그룹 이름
    var createdAt: Date         //그룹 생성 날짜
    var leader: String          //그룹 장
    var members: [String]        //그룹 원 이릌
    var memberIDs: [String]     // 그룹원 uid 목록
    
}
