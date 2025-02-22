//
//  PersonalSchedule.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct PersonalSchedule: Identifiable, Codable {
    @DocumentID var id: String?
    var userID: String          //사용자 ID
    var name: String            //개인 일정 이름
    var content: String         //개인 일정 내용
    var createdAt: Timestamp         //일정 생성 날짜
    var schedule: [TimeSlotPersonal]    //개인 일정 날짜, 시간
    var groupID: [String]         //개인 일정을 공유한 그룹
}

struct TimeSlotPersonal: Codable {
    var startTime: Date  // 시작 시간
    var endTime: Date    // 종료 시간
}
