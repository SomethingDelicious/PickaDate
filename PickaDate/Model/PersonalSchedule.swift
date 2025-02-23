//
//  PersonalSchedule.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

let colors: [String] = ["red", "orange", "yellow", "green", "blue", "purple", "brown"]
let colorMap: [String: Color] = [
    "red": .red,
    "orange": .orange,
    "yellow": .yellow,
    "green": .green,
    "blue": .blue,
    "purple": .purple,
    "brown": .brown
]

struct PersonalSchedule: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String          //사용자 ID
    var name: String            //개인 일정 이름
    var content: String         //개인 일정 내용
    var createdAt: Timestamp         //일정 생성 날짜
    var schedule: [TimeSlotPersonal]    //개인 일정 날짜, 시간
    var groupID: [String]         //개인 일정을 공유한 그룹
    var personalColor: String
    
    var color: Color {
        colorMap[personalColor, default: .green]
    }
}

struct TimeSlotPersonal: Codable {
    var startTime: Date  // 시작 시간
    var endTime: Date    // 종료 시간
    var isAllDay: Bool
    
    init(startTime: Date, endTime: Date, isAllDay: Bool = false) {
        self.startTime = isAllDay ? Calendar.current.startOfDay(for: startTime) : startTime
        self.endTime = isAllDay ? Calendar.current.date(byAdding: .day, value: 1, to: startTime)?.addingTimeInterval(-1) ?? endTime : endTime
        self.isAllDay = isAllDay
    }
}
