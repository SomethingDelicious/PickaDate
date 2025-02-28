//
//  GroupViewModel.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

class GroupViewModel: ObservableObject {
    let fsDB = Firestore.firestore()
    @Published var groups: [Group] = []
    
    // 그룹 정보 가져오기
    func fetchGroups() {
        fsDB.collection("groups").getDocuments { snapshot, error in
            if let error = error {
                print("[E]그룹 가져오기 실패: \(error.localizedDescription)")
                return
            }
            print("[L]그룹 가져오기 성공")
            DispatchQueue.main.async {
                self.groups = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Group.self)
                } ?? []
            }
        }
    }
    
    // 그룹 추가하기
    func addGroup(groupID: String, leader: String, member: [String]) {
        let groupData: [String: Any] = [
            "groupID": groupID,
            "createdAt": FieldValue.serverTimestamp(),
            "leader": leader,
            "member": member
        ]
        
        fsDB.collection("groups").document(groupID).setData(groupData) { error in
            if let error = error {
                print("[E]그룹 추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]그룹 추가 성공")
                self.fetchGroups()
            }
        }
    }
    
    // MARK: - 멤버 관리 메서드
    // 그룹 멤버 목록 가져오기
    func fetchGroupMembers(groupID: String) {
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
            
            // 업데이트는 메인 스레드에서
            DispatchQueue.main.async {
                if let index = self.groups.firstIndex(where: { $0.groupID == groupID }) {
                    self.groups[index] = group
                } else {
                    self.groups.append(group)
                }
            }
        }
    }
    // 해당 그룹의 멤버 목록 반환
    func getGroupMembers(groupID: String) -> [String] {
        if let group = groups.first(where: { $0.groupID == groupID }) {
            return group.members
        }
        return []
    }
    
    // 멤버 추가하기
    func addMemberToGroup(groupID: String, memberID: String) {
        fsDB.collection("groups").document(groupID).updateData([
            "members": FieldValue.arrayUnion([memberID])
        ]) { error in
            if let error = error {
                print("[E]멤버 추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]멤버 추가 성공")
                self.fetchGroups()
            }
        }
    }
    
    // 멤버 삭제하기
    func removeMemberFromGroup(groupID: String, memberID: String) {
        fsDB.collection("groups").document(groupID).updateData([
            "members": FieldValue.arrayRemove([memberID])
        ]) { error in
            if let error = error {
                print("[E]멤버 삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]멤버 삭제 성공")
                self.fetchGroups()
            }
        }
    }
    
    // 그룹의 멤버 일정 상태 가져오기
    func getMemberScheduleStatus(groupID: String, date: Date, completion: @escaping (Int, Int) -> Void) {
        guard let group = groups.first(where: { $0.groupID == groupID }) else {
            completion(0, 0)
            return
        }
        
        let members = group.members
        
        // 해당 날짜에 일정이 있는 멤버 ID 목록 가져오기
        fsDB.collection("personalSchedule")
            .whereField("userID", in: members)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E]일정 가져오기 실패: \(error.localizedDescription)")
                    completion(0, members.count)
                    return
                }
                
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!.addingTimeInterval(-1)
                
                var membersWithSchedule = Set<String>()
                
                // 일정이 있는 멤버 찾기
                for document in snapshot?.documents ?? [] {
                    if let schedule = try? document.data(as: PersonalSchedule.self) {
                        for timeSlot in schedule.schedule {
                            // 해당 날짜에 일정이 있는지 확인
                            if (timeSlot.startTime <= endOfDay && timeSlot.endTime >= startOfDay) {
                                membersWithSchedule.insert(schedule.userID)
                                break
                            }
                        }
                    }
                }
                
                let withScheduleCount = membersWithSchedule.count
                let withoutScheduleCount = members.count - withScheduleCount
                
                DispatchQueue.main.async {
                    completion(withScheduleCount, withoutScheduleCount)
                }
            }
    }
}
    

