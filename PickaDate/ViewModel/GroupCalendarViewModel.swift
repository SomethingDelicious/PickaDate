//
//  GroupCalendarViewModel.swift
//  PickaDate
//
//  Created by NoelMacMini on 2/23/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class GroupCalendarViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var groupSchedules: [PDGroupSchedule] = []
    @Published var groupProposals: [GroupScheduleProposal] = []
    @Published var dailyScheduleStatus: [String: (withSchedule: Int, withoutSchedule: Int)] = [:]
    
    
    // 특정 그룹의 일정 가져오기
    func fetchGroupSchedules(groupID: String) {
        fsDB.collection("groupSchedules")
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.groupSchedules = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: PDGroupSchedule.self)
                    } ?? []
                    print("[L]그룹 일정 가져오기 성공: \(self.groupSchedules.count)개")
                }
        }
    }
    
    // 그룹 일정 제안 가져오기
    func fetchGroupProposals(for groupID: String) {
        fsDB.collection("groupScheduleProposals")
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E]그룹 일정 제안 가져오기 실패: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.groupProposals = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: GroupScheduleProposal.self)
                    } ?? []
                    print("[L]그룹 일정 제안 가져오기 성공: \(self.groupProposals.count)개")
                }
            }
    }
    
    // 그룹 일정 제안하기
    func proposeGroupSchedule(
        groupID: String,
        groupName: String,
        title: String,
        content: String,
        creator: String,
        schedule: [TimeSlotGroup],
        groupColor: String,
        members: [String],
        completion: @escaping (Bool) -> Void
    ) {
        // 그룹 스케줄 프로포절 생성
        let proposalID = UUID().uuidString
        
        let proposalData: [String: Any] = [
            "proposalID": proposalID,
            "groupID": groupID,
            "groupName": groupName,
            "title": title,
            "content": content,
            "creator": creator,
            "createdAt": FieldValue.serverTimestamp(),
            "schedule": schedule.map { slot in
                return [
                    "startTime": slot.startTime,
                    "endTime": slot.endTime,
                    "isAllDay": slot.isAllDay
                ] as [String: Any]
            },
            "votes": [:], // 빈 투표 맵으로 시작
            "groupColor": groupColor,
            "status": "pending" // 상태는 pending으로 시작
        ]
        
        fsDB.collection("groupScheduleProposals").document(proposalID).setData(proposalData) { error in
            if let error = error {
                print("[E]그룹 일정 제안 추가 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("[L]그룹 일정 제안 추가 성공")
                self.fetchGroupProposals(for: groupID)
                completion(true)
            }
        }
    }
    
    // 특정 날짜의 일정 상태 가져오기
    func getScheduleStatusForDate(_ date: Date) -> (withSchedule: Int, withoutSchedule: Int) {
        // 날짜를 문자열 키로 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateKey = dateFormatter.string(from: date)
        
        // 해당 날짜의 상태 반환
        return dailyScheduleStatus[dateKey] ?? (0, 0)
    }
    
    // 특정 날짜에 대한 그룹 일정 제안 가져오기
    func getGroupProposalForDate(_ date: Date) -> [GroupScheduleProposal] {
        return groupProposals.filter { proposal in
            proposal.schedule.contains { timeSlot in
                Calendar.current.isDate(date, inSameDayAs: timeSlot.startTime) ||
                Calendar.current.isDate(date, inSameDayAs: timeSlot.endTime) ||
                (date >= timeSlot.startTime && date <= timeSlot.endTime)
            }
        }
    }
    
    // 월별 일정 상태 계산하기
    func calculateMonthScheduleStatus(groupID: String, year: Int, month: Int) {
        // 현재 사용자 ID 가져오기
        guard let currentUser = Auth.auth().currentUser?.uid else {
            print("[E]로그인된 사용자가 없습니다.")
            return
        }
        
        // 그룹 멤버 가져오기
        fsDB.collection("groups").document(groupID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[E]그룹 정보 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            guard let groupDoc = snapshot, groupDoc.exists else {
                print("[E]그룹을 찾을 수 없습니다.")
                return
            }
            
            // 그룹 멤버 목록 추출
            guard let members = groupDoc.data()?["member"] as? [String] else {
                print("[E]그룹 멤버 정보가 없습니다.")
                return
            }
            
            // 해당 월의 첫날과 마지막날 구하기
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = 1
            
            guard let startDate = calendar.date(from: dateComponents),
                  let nextMonth = calendar.date(byAdding: .month, value: 1, to: startDate),
                  let endDate = calendar.date(byAdding: .day, value: -1, to: nextMonth) else {
                return
            }
            
            // 각 멤버의 일정 확인
            var memberSchedules: [String: [Date: Bool]] = [:] // [멤버ID: [날짜: 일정있음]]
            let group = DispatchGroup()
            
            for member in members {
                group.enter()
                
                // 사용자 일정 가져오기
                self.fsDB.collection("userSchedules")
                    .whereField("userID", isEqualTo: member)
                    .getDocuments { snapshot, error in
                        defer { group.leave() }
                        
                        if let error = error {
                            print("[E]사용자 일정 가져오기 실패: \(error.localizedDescription)")
                            return
                        }
                        
                        var dateHasSchedule: [Date: Bool] = [:]
                        
                        // 사용자 일정 처리
                        if let documents = snapshot?.documents {
                            for document in documents {
                                if let userSchedule = try? document.data(as: PDUserSchedule.self) {
                                    for slot in userSchedule.schedule {
                                        let slotStartDate = calendar.startOfDay(for: slot.startTime)
                                        let slotEndDate = calendar.startOfDay(for: slot.endTime)
                                        
                                        // 슬롯의 각 날짜에 대해 일정 있음으로 표시
                                        var current = slotStartDate
                                        while current <= slotEndDate {
                                            dateHasSchedule[current] = true
                                            current = calendar.date(byAdding: .day, value: 1, to: current)!
                                        }
                                    }
                                }
                            }
                        }
                        
                        memberSchedules[member] = dateHasSchedule
                    }
            }
            
            group.notify(queue: .main) {
                // 날짜별로 일정 있는 멤버 수와 없는 멤버 수 계산
                var newDailyStatus: [String: (withSchedule: Int, withoutSchedule: Int)] = [:]
                
                var current = startDate
                while current <= endDate {
                    let currentDay = calendar.startOfDay(for: current)
                    
                    // 해당 날짜에 일정 있는 멤버 수 계산
                    var withScheduleCount = 0
                    for (_, dateMap) in memberSchedules {
                        if dateMap[currentDay] == true {
                            withScheduleCount += 1
                        }
                    }
                    
                    // 일정 없는 멤버 수 계산
                    let withoutScheduleCount = members.count - withScheduleCount
                    
                    // 날짜를 문자열 키로 변환
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let dateKey = dateFormatter.string(from: currentDay)
                    
                    // 상태 저장
                    newDailyStatus[dateKey] = (withScheduleCount, withoutScheduleCount)
                    
                    // 다음 날짜로 이동
                    current = calendar.date(byAdding: .day, value: 1, to: current)!
                }
                
                // 상태 업데이트
                self.dailyScheduleStatus = newDailyStatus
                print("[L]월별 일정 상태 계산 완료: \(newDailyStatus.count)일")
            }
        }
    }

    
    // 그룹 일정 추가하기
    func addGroupSchedule(groupID: String, title: String, content: String, schedule: [TimeSlotGroup], groupColor: String) {
        let scheduleData = schedule.map { slot in
            return [
                "startTime": slot.startTime,
                "endTime": slot.endTime
            ] as [String: Any]
        }
        
        let groupSchedule: [String: Any] = [
            "groupID": groupID,
            "title": title,
            "content": content,
            "createdAt": FieldValue.serverTimestamp(),
            "schedule": scheduleData,
            "groupColor": groupColor
        ]
        
        fsDB.collection("groupSchedules").document().setData(groupSchedule) { error in
            if let error = error {
                print("[E]그룹 일정 추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]그룹 일정 추가 성공")
                self.fetchGroupSchedules(groupID: groupID)
            }
        }
    }
    
    // 그룹 일정 업데이트하기
    func updateGroupSchedule(scheduleID: String, groupID: String, title: String, content: String, schedule: [TimeSlotGroup], groupColor: String) {
        let scheduleData = schedule.map { slot in
            return [
                "startTime": slot.startTime,
                "endTime": slot.endTime
            ] as [String: Any]
        }
        
        let updatedSchedule: [String: Any] = [
            "groupID": groupID,
            "title": title,
            "content": content,
            "updatedAt": FieldValue.serverTimestamp(),
            "schedule": scheduleData,
            "groupColor": groupColor
        ]
        
        fsDB.collection("groupSchedules").document(scheduleID).updateData(updatedSchedule) { error in
            if let error = error {
                print("[E]그룹 일정 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("[L]그룹 일정 업데이트 성공")
                self.fetchGroupSchedules(groupID: groupID)
            }
        }
    }
    
    // 그룹 일정 삭제하기
    func deleteGroupSchedule(scheduleID: String, groupID: String) {
        fsDB.collection("groupSchedules").document(scheduleID).delete { error in
            if let error = error {
                print("[E]그룹 일정 삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]그룹 일정 삭제 성공")
                self.fetchGroupSchedules(groupID: groupID)
            }
        }
    }
}
