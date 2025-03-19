//
//  GroupSchedule.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct PDGroupSchedule: Identifiable, Codable {
    @DocumentID var id: String?
    var groupID: String             //그룹 이름
    var name: String                //그룹 일정 이름
    var content: String             //그룹 일정 내용
    var createdAt: Date             //일정 생성 날짜
    var schedule: [TimeSlotGroup]   //그룹 일정 날짜, 시간
    
    var groupColor: String
    
    var color: Color {
        colorMap[groupColor, default: .blue]
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

//MARK: - from Test
 enum ScheduleStatus: String, Codable {
     case planned = "planned"     // 예정 일정
     case confirmed = "confirmed" // 확정 일정
 }
 
struct GroupSchedule: Identifiable, Codable {
    @DocumentID var id: String?
    var groupID: String             // 그룹 ID
    var title: String               // 그룹 일정 제목
    var content: String             // 그룹 일정 내용
    var createdAt: Date             // 일정 생성 날짜
    var schedule: [TimeSlotGroup]   // 그룹 일정 날짜, 시간
    var status: ScheduleStatus      // 일정 상태 (예정/확정)
    var creator: String             // 일정 생성자 ID
    var checkedMembers: [String]    // 체크된 참여자 ID 목록
    var unCheckedMembers: [String]  // 체크 안된 참여자 ID 목록
    var participants: [String]      // 참여자 ID 목록
    var nonParticipants: [String]   // 불참자 ID 목록
    var groupColor: String          // 그룹 일정 색상
    
    var color: Color {
        colorMap[groupColor, default: .blue]
    }
    
    // 기본 생성자
    init() {
        self.groupID = ""
        self.title = ""
        self.content = ""
        self.createdAt = Date()
        self.schedule = []
        self.status = .planned
        self.creator = ""
        self.checkedMembers = []
        self.unCheckedMembers = []
        self.participants = []
        self.nonParticipants = []
        self.groupColor = "blue"
    }
    
    // 제안 일정 생성자
    init(groupID: String, title: String, content: String, creator: String, schedule: [TimeSlotGroup], groupColor: String = "blue") {
        self.groupID = groupID
        self.title = title
        self.content = content
        self.createdAt = Date()
        self.schedule = schedule
        self.status = .planned
        self.creator = creator
        self.checkedMembers = []
        self.unCheckedMembers = []
        self.participants = []
        self.nonParticipants = []
        self.groupColor = groupColor
    }
    
    
    
    // 그룹원의 일정 상태를 가져오는 함수
    func getMemberScheduleStatus(allMembers: [String], membersWithSchedule: [String]) -> (withSchedule: Int, withoutSchedule: Int) {
        let withScheduleCount = membersWithSchedule.count
        let withoutScheduleCount = allMembers.count - withScheduleCount
        
        return (withSchedule: withScheduleCount, withoutSchedule: withoutScheduleCount)
    }
}
