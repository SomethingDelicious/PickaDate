//
//  GroupScheduleProposal.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/20/25.
//

import SwiftUI
import FirebaseFirestore

// 그룹 일정 제안을 위한 모델
struct GroupScheduleProposal: Identifiable, Codable {
    @DocumentID var id: String?
    var proposalID: String       // 제안 ID
    var groupID: String          // 그룹 ID
    var title: String            // 제목
    var content: String          // 내용
    var creator: String          // 제안자 ID
    var createdAt: Date          // 생성 일시
    var schedule: [TimeSlotGroup] // 일정 시간
    var votes: [String: String]  // [사용자ID: 선택한 일정 인덱스]
    var groupColor: String       // 색상
    var status: String           // 상태 (pending, approved, rejected)
}
