//
//  GroupSchedule.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupSchedule: Identifiable, Codable {
    @DocumentID var id: String?
    var groupID: String             //그룹 이름
    var name: String                //그룹 일정 이름
    var content: String             //그룹 일정 내용
    var createdAt: Date             //일정 생성 날짜
    var schedule: [TimeSlotGroup]   //그룹 일정 날짜, 시간
}

struct TimeSlotGroup: Codable {
    var startTime: Date  // 시작 시간
    var endTime: Date    // 종료 시간
}
