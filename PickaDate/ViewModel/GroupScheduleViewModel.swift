//
//  GroupScheduleViewModel.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

class GroupScheduleViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var personalSchedule: [PersonalSchedule] = []
    @Published var groupSchedule: [GroupSchedule] = []
    @Published var groupProposals: [GroupScheduleProposal] = []
    @Published var memberScheduleStatuses: [Date: (withSchedule: Int, withoutSchedule: Int)] = [:]
    
    // MARK: - GroupSchedule CRUD 메서드
    // 그룹 일정 가져오기
    func fetchGroupSchedules(groupID: String) {
        fsDB.collection("groupSchedule")
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { snapshot, error in
            if let error = error {
                print("[E]그룹 일정 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.groupSchedule = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: GroupSchedule.self)
                } ?? []
                print("[L]그룹 일정 가져오기 성공: \(self.groupSchedule.count)개")
            }
        }
    }
    
    // 그룹 일정 제안하기 (status = planned)
    func proposeGroupSchedule(
        groupID: String,
        title: String,
        content: String,
        creator: String,
        schedule: [TimeSlotGroup],
        groupColor: String,
        members: [String],
        completion: @escaping (Bool) -> Void
    ) {
        // 새 GroupSchedule 객체 생성
        let newSchedule = GroupSchedule(
            groupID: groupID,
            title: title,
            content: content,
            creator: creator,
            schedule: schedule,
            groupColor: groupColor
        )
        
        // 모든 멤버를 unCheckedMembers로 설정
        var scheduleData: [String: Any] = [
            "groupID": newSchedule.groupID,
            "title": newSchedule.title,
            "content": newSchedule.content,
            "createdAt": FieldValue.serverTimestamp(),
            "schedule": newSchedule.schedule.map { timeSlot in
                return [
                    "startTime": timeSlot.startTime,
                    "endTime": timeSlot.endTime,
                    "isAllDay": timeSlot.isAllDay
                ]
            },
            "status": newSchedule.status.rawValue,
            "creator": newSchedule.creator,
            "checkedMembers": [],
            "unCheckedMembers": members,
            "participants": [],
            "nonParticipants": [],
            "groupColor": newSchedule.groupColor
        ]
        
        // Firestore에 저장
        let docRef = fsDB.collection("groupSchedules").document()
        docRef.setData(scheduleData) { error in
            if let error = error {
                print("[E]그룹 일정 제안 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("[L]그룹 일정 제안 성공")
                self.fetchGroupSchedules(groupID: groupID)
                completion(true)
            }
        }
    }
    
    // 그룹 일정 확정하기 (status = confirmed)
    func confirmGroupSchedule(scheduleID: String, participants: [String], nonParticipants: [String], completion: @escaping (Bool) -> Void) {
        let docRef = fsDB.collection("groupSchedules").document(scheduleID)
        
        docRef.updateData([
            "status": ScheduleStatus.confirmed.rawValue,
            "participants": participants,
            "nonParticipants": nonParticipants
        ]) { error in
            if let error = error {
                print("[E]그룹 일정 확정 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("[L]그룹 일정 확정 성공")
                completion(true)
            }
        }
    }
    
    // 멤버 체크 상태 업데이트
    func updateMemberStatus(
        scheduleID: String,
        memberID: String,
        isParticipating: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        let docRef = fsDB.collection("groupSchedules").document(scheduleID)
        
        // 트랜잭션 사용하여 안전하게 업데이트
        fsDB.runTransaction({ (transaction, errorPointer) -> Any? in
            let document: DocumentSnapshot
            do {
                try document = transaction.getDocument(docRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            guard let data = document.data(),
                  var checkedMembers = data["checkedMembers"] as? [String],
                  var unCheckedMembers = data["unCheckedMembers"] as? [String],
                  var participants = data["participants"] as? [String],
                  var nonParticipants = data["nonParticipants"] as? [String]
            else { return nil }
            
            // 체크 상태 업데이트
            if !checkedMembers.contains(memberID) {
                checkedMembers.append(memberID)
                unCheckedMembers.removeAll { $0 == memberID }
            }
            
            // 참여 상태 업데이트
            if isParticipating {
                if !participants.contains(memberID) {
                    participants.append(memberID)
                }
                nonParticipants.removeAll { $0 == memberID }
            } else {
                if !nonParticipants.contains(memberID) {
                    nonParticipants.append(memberID)
                }
                participants.removeAll { $0 == memberID }
            }
            
            transaction.updateData([
                "checkedMembers": checkedMembers,
                "unCheckedMembers": unCheckedMembers,
                "participants": participants,
                "nonParticipants": nonParticipants
            ], forDocument: docRef)
            
            return nil
        }) { (_, error) in
            if let error = error {
                print("[E]멤버 상태 업데이트 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("[L]멤버 상태 업데이트 성공")
                completion(true)
            }
        }
    }
    
    // 그룹 일정 삭제
    func deleteGroupSchedule(scheduleID: String, completion: @escaping (Bool) -> Void) {
        fsDB.collection("groupSchedules").document(scheduleID).delete { error in
            if let error = error {
                print("[E]그룹 일정 삭제 실패: \(error.localizedDescription)")
                completion(false)
            } else {
                print("[L]그룹 일정 삭제 성공")
                completion(true)
            }
        }
    }
    // MARK: -
    
    // 그룹 멤버의 일정 가져오기
    func fetchGroupMemberSchedules(groupID: String, completion: @escaping () -> Void) {
        // 먼저 그룹 정보 가져오기
        fsDB.collection("Group").document(groupID).getDocument { snapshot, error in
            if let error = error {
                print("[E]그룹 정보 가져오기 실패: \(error.localizedDescription)")
                completion()
                return
            }
            
            guard let document = snapshot, document.exists,
                  let group = try? document.data(as: Group.self) else {
                print("[E]그룹 정보 없음")
                completion()
                return
            }
            
            // 그룹 멤버들의 일정 가져오기
            self.fsDB.collection("personalSchedule")
                .whereField("userID", in: group.members)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("[E]멤버 일정 가져오기 실패: \(error.localizedDescription)")
                        completion()
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.personalSchedule = snapshot?.documents.compactMap { doc in
                            try? doc.data(as: PersonalSchedule.self)
                        } ?? []
                        print("[L]멤버 일정 가져오기 성공: \(self.personalSchedule.count)개")
                        completion()
                    }
                }
        }
    }
    
    // 특정 달(month)의 모든 날짜에 대해 일정 상태 계산하기
    func calculateMonthScheduleStatus(groupID: String, year: Int, month: Int) {
        // 먼저 그룹 정보 가져오기
        fsDB.collection("groups").document(groupID).getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("[E]그룹 정보 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot, document.exists,
                  let group = try? document.data(as: Group.self) else {
                print("[E]그룹 정보 없음")
                return
            }
            
            let members = group.members
            
            // 해당 월의 모든 날짜 구하기
            let calendar = Calendar.current
            var dateComponents = DateComponents()
            dateComponents.year = year
            dateComponents.month = month
            dateComponents.day = 1
            
            guard let firstDayOfMonth = calendar.date(from: dateComponents),
                  let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
                return
            }
            
            let daysInMonth = range.count
            
            // 멤버들의 모든 일정 가져오기 (한 번에)
            self.fsDB.collection("personalSchedule")
                .whereField("userID", in: members)
                .getDocuments { [weak self] snapshot, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("[E]멤버 일정 가져오기 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    // 모든 개인 일정을 메모리에 로드
                    let allSchedules = snapshot?.documents.compactMap { doc -> PersonalSchedule? in
                        try? doc.data(as: PersonalSchedule.self)
                    } ?? []
                    
                    // 각 날짜별로 일정 상태 계산
                    var newStatuses: [Date: (withSchedule: Int, withoutSchedule: Int)] = [:]
                    
                    for day in 1...daysInMonth {
                        dateComponents.day = day
                        guard let date = calendar.date(from: dateComponents) else { continue }
                        
                        let startOfDay = calendar.startOfDay(for: date)
                        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
                        
                        // 이 날짜에 일정이 있는 멤버 ID 집합
                        var membersWithSchedule = Set<String>()
                        
                        // 모든 일정을 확인하여 이 날짜에 해당하는 일정이 있는 멤버 찾기
                        for schedule in allSchedules {
                            for timeSlot in schedule.schedule {
                                // 날짜 범위가 겹치는지 확인
                                if timeSlot.startTime <= endOfDay && timeSlot.endTime >= startOfDay {
                                    membersWithSchedule.insert(schedule.userID)
                                    break // 한 명이 여러 일정을 가지고 있더라도 한 번만 카운트
                                }
                            }
                        }
                        
                        // 결과 저장
                        let withScheduleCount = membersWithSchedule.count
                        let withoutScheduleCount = members.count - withScheduleCount
                        newStatuses[startOfDay] = (withSchedule: withScheduleCount, withoutSchedule: withoutScheduleCount)
                    }
                    
                    // UI 업데이트는 메인 스레드에서
                    DispatchQueue.main.async {
                        self.memberScheduleStatuses = newStatuses
                    }
                }
        }
    }
    
    // 특정 날짜에 일정이 있는 멤버와 없는 멤버 수 가져오기
    func getScheduleStatusForDate(_ date: Date) -> (withSchedule: Int, withoutSchedule: Int) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        return memberScheduleStatuses[startOfDay] ?? (withSchedule: 0, withoutSchedule: 0)
    }
    
    func fetchPersonalSchedules() {
        fsDB.collection("personalSchedule").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.personalSchedule = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PersonalSchedule.self)
                } ?? []
            }
        }
    }
    

    
    
    
    func addPersonalSchedule(userID: String, name: String, content: String, groupID: [String], schedule: [TimeSlotPersonal], personalColor: String) {
        let scheduleData = schedule.map { slot in
            return [
                "startTime": slot.startTime,
                "endTime": slot.endTime
            ]
        }
        
        let personalSchedule: [String: Any] = [
            "userID": userID,
            "name": name,
            "content": content,
            "createdAt": FieldValue.serverTimestamp(),
            "schedule": scheduleData,
            "groupID": groupID,
            "personalColor" : personalColor
        ]
        
        fsDB.collection("personalSchedule").document().setData(personalSchedule) { error in
            if let error = error {
                print("[E]추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]문서 추가 성공")
                self.fetchPersonalSchedules()
            }
        }
    }
    
    func deletePersonalSchedule(userId: String) {
        fsDB.collection("personalSchedule").document(userId).delete { error in
            if let error = error {
                print("[E]삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]삭제 성공")
                self.fetchPersonalSchedules()
            }
        }
    }
    // MARK: - GroupScheduleViewModel 메서드
    // 날짜 셀에 진행 중인 그룹일정제안 표시
    func getGroupProposalForDate(_ date: Date) -> [GroupScheduleProposal] {
        return groupProposals.filter { proposal in
            proposal.proposals.contains { proposalOption in
                proposalOption.dates.contains { proposalDate in
                    Calendar.current.isDate(date, inSameDayAs: proposalDate)
                }
            }
        }
    }
    
    func fetchGroupProposals(for groupID: String) {
        fsDB.collection("groupProposals")
            .whereField("groupID", isEqualTo: groupID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E]그룹 제안 가져오기 실패: \(error.localizedDescription)")
                    return
                }

                DispatchQueue.main.async {
                    self.groupProposals = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: GroupScheduleProposal.self)
                    } ?? []
                    print("[L]그룹 제안 가져오기 성공: \(self.groupProposals.count)개")
                }
            }
    }
    

}

