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
    var proposalID: String          // 제안 ID
    var groupID: String             // 그룹 ID
    var groupName: String           // 그룹 이름
    var title: String               // 제목
    var content: String             // 내용
    var creator: String             // 제안자 ID
    var creatorName: String         // 제안자 userName
    var createdAt: Date             // 생성 일시
    var schedule: [TimeSlotGroup]   // 일정 시간
    var checkedMembers: [String]    // 확인 완료한 멤버 ID 목록
    var unCheckedMembers: [String]  // 확인 안한 멤버 ID 목록
    var memberAvailability: [String: [String: Bool]] // 각 멤버별 각 후보에 대한 가능/불가능 상태  // [멤버ID: [옵션인덱스: 가능여부]]
    var groupColor: String          // 색상
    var status: ProposalStatus      // 상태 (pending, confirmed, canceled)
    var confirmedOptionIndex: Int?  // 확정된 경우, 선택된 옵션 인덱스
    
    // 기본 생성자
    init() {
        self.proposalID = UUID().uuidString
        self.groupID = ""
        self.groupName = ""
        self.title = ""
        self.content = ""
        self.creator = ""
        self.creatorName = ""
        self.createdAt = Date()
        self.schedule = []
        self.checkedMembers = []
        self.unCheckedMembers = []
        self.memberAvailability = [:]
        self.groupColor = "blue"
        self.status = .pending
        self.confirmedOptionIndex = nil
    }
    
    // 상세 정보로 초기화하는 생성자
    init(groupID: String, groupName: String, title: String, content: String,
         creator: String, creatorName: String, schedule: [TimeSlotGroup],
         groupMembers: [String], groupColor: String = "blue") {
        
        self.proposalID = UUID().uuidString
        self.groupID = groupID
        self.groupName = groupName
        self.title = title
        self.content = content
        self.creator = creator
        self.creatorName = creatorName
        self.createdAt = Date()
        self.schedule = schedule
        self.checkedMembers = []              // 처음에는 아무도 체크하지 않음
        self.unCheckedMembers = groupMembers  // 모든 그룹 멤버를 미체크 상태로 설정
        self.memberAvailability = [:]         // 처음에는 빈 상태
        self.groupColor = groupColor
        self.status = .pending
        self.confirmedOptionIndex = nil
    }
}

enum ProposalStatus: String, Codable {
    case pending    // 진행 중
    case confirmed  // 확정됨
    case canceled   // 취소됨
}
