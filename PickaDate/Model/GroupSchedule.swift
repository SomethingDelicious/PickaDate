//
//  GroupSchedule.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

enum ScheduleStatus: String, Codable {
    case planned = "planned"     // 예정 일정
    case confirmed = "confirmed" // 확정 일정
    case canceled = "canceled"   // 취소된 일정
}

struct PDGroupSchedule: Identifiable, Codable {
    @DocumentID var id: String?
    var groupID: String             //그룹 이름
    var groupName: String           // 그룹 이름
    var title: String                //그룹 일정 이름
    var content: String             //그룹 일정 내용
    var createdAt: Date             //일정 생성 날짜
    var schedule: TimeSlotGroup   //그룹 일정 날짜, 시간
    var status: ScheduleStatus      // 일정 상태 (예정/확정)
    var creator: String             // 일정 생성자 ID
    var creatorName: String         // 일정 생성자 이름
    var originalProposalID: String? // 원본 제안 ID (연결용)
    
    // 참여/불참 상태
    var participants: [String]      // 참여자 ID 목록
    var nonParticipants: [String]   // 불참자 ID 목록
    
    var groupColor: String          //그룹 색상
    
    var color: Color {
        colorMap[groupColor, default: .blue]
    }
    
    // 기본 생성자
    init() {
        self.groupID = ""
        self.groupName = ""
        self.title = ""
        self.content = ""
        self.createdAt = Date()
        self.schedule = TimeSlotGroup(startTime: Date(), endTime: Date())
        self.status = .planned
        self.creator = ""
        self.creatorName = ""
        self.originalProposalID = nil
        self.participants = []
        self.nonParticipants = []
        self.groupColor = "blue"
    }
    
    // 제안에서 변환하는 생성자
    init(from proposal: GroupScheduleProposal, selectedOptionIndex: Int) {
        self.groupID = proposal.groupID
        self.groupName = proposal.groupName
        self.title = proposal.title
        self.content = proposal.content
        self.createdAt = Date()
        
        // 선택된 옵션의 일정 시간 사용
        if selectedOptionIndex < proposal.schedules.count {
            self.schedule = proposal.schedules[selectedOptionIndex]
        } else {
            // 기본값 설정
            self.schedule = TimeSlotGroup(startTime: Date(), endTime: Date())
        }
        
        self.status = .confirmed
        self.creator = proposal.creator
        self.creatorName = proposal.creatorName
        self.originalProposalID = proposal.proposalID
        
        // 가능한 멤버는 참여, 불가능한 멤버는 불참으로 초기 설정
        self.participants = []
        self.nonParticipants = []
        
        // 각 멤버의 가능 여부에 따라 참여/불참 초기화
        for (memberID, availabilityMap) in proposal.memberAvailability {
            if let isAvailable = availabilityMap[String(selectedOptionIndex)], isAvailable {
                self.participants.append(memberID)
            } else {
                self.nonParticipants.append(memberID)
            }
        }
        
        self.groupColor = proposal.groupColor
    }
}

struct TimeSlotGroup: Codable {
    var startTime: Date  // 시작 시간
    var endTime: Date    // 종료 시간
    var isAllDay: Bool   // 종일 여부
     
     init(startTime: Date, endTime: Date, isAllDay: Bool = false) {
         if isAllDay {
             self.startTime = Calendar.current.startOfDay(for: startTime)
             self.endTime = Calendar.current.date(byAdding: .day, value: 1, to: startTime)?.addingTimeInterval(-1) ?? endTime
         } else {
             self.startTime = startTime
             self.endTime = endTime
         }
         self.isAllDay = isAllDay
     }
 }
