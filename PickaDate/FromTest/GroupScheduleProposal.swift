//
//  GroupScheduleProposal.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupScheduleProposal: Identifiable, Codable {
    @DocumentID var id: String?
    var proposalID: String       // 제안 ID
    var groupID: String          // 그룹 ID
    var title: String            // 제안 제목
    var description: String      // 제안 설명
    var createdAt: Date          // 제안 생성 날짜
    var createdBy: String        // 제안자 ID
    var proposals: [Proposal]    // 일정 후보 목록
    var status: ProposalStatus   // 제안 상태
}

struct Proposal: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String            // 후보 제목
    var dates: [Date]            // 후보 날짜 목록
    var votes: [String]          // 투표한 사용자 ID 목록
}

enum ProposalStatus: String, Codable {
    case pending    // 진행 중
    case confirmed  // 확정됨
    case canceled   // 취소됨
}
