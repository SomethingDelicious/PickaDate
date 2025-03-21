//
//  GroupViewModel.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class GroupViewModel: ObservableObject {
    let fsDB = Firestore.firestore()
    @Published var groups: [PDGroup] = []
    @Published var currentGroup: PDGroup? // 현재 선택된 그룹
    @Published var groupMembers: [String] = [] // 그룹 멤버 목록
    
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
                    try? doc.data(as: PDGroup.self)
                } ?? []
            }
        }
    }
    
    // 사용자의 그룹 정보 가져오기
    func fetchUserGroups() {
        // 현재 로그인한 사용자 ID 확인
        guard let userID = Auth.auth().currentUser?.uid else {
            print("[E]로그인된 사용자가 없습니다.")
            return
        }
        
        // 사용자가 속한 그룹만 가져오기
        fsDB.collection("groups")
            .whereField("memberIDs", arrayContains: userID)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E]사용자 그룹 가져오기 실패: \(error.localizedDescription)")
                    return
                }
                
                DispatchQueue.main.async {
                    self.groups = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: PDGroup.self)
                    } ?? []
                    print("[L]사용자 그룹 가져오기 성공: \(self.groups.count)개")
                    
                    // 현재 그룹이 설정되지 않았다면 첫 번째 그룹으로 설정
                    if self.currentGroup == nil && !self.groups.isEmpty {
                        self.setCurrentGroup(self.groups[0])
                    }
                }
            }
    }
    
    // 그룹 추가하기
    func addGroup(groupName: String, leader: String, leaderID: String, members: [String], memberIDs: [String]) {
        let groupID = UUID().uuidString
        let groupData: [String: Any] = [
            "groupID": groupID,
            "groupName": groupName,
            "createdAt": FieldValue.serverTimestamp(),
            "leader": leader,
            "leaderID": leaderID,
            "members": members,
            "memberIDs": memberIDs
        ]
        
        fsDB.collection("groups").document(groupID).setData(groupData) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("[E]그룹 추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]그룹 추가 성공")
                
                // 모든 멤버의 joinedGroups 및 joinedGroupsUID 업데이트
                self.updateUsersGroupMemberships(userIDs: memberIDs, groupID: groupID, groupName: groupName)
                
                self.fetchGroups()
            }
        }
    }
    
    // 현재 그룹 설정하기
    func setCurrentGroup(_ group: PDGroup) {
        self.currentGroup = group
        
        // 현재 그룹의 멤버 정보 가져오기
        fetchGroupMembers(groupID: group.groupID)
        
        // 사용자의 onGroup 필드 업데이트
        updateUserOnGroup(group.groupID)
        
        print("[L]현재 그룹 설정: \(group.groupName)")
    }
    
    // 사용자의 onGroup 필드 업데이트
    private func updateUserOnGroup(_ groupID: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("[E]로그인된 사용자가 없습니다.")
            return
        }
        
        // Firestore의 사용자 문서 업데이트
        fsDB.collection("users").document(userID).updateData([
            "onGroup": groupID
        ]) { error in
            if let error = error {
                print("[E]사용자 onGroup 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("[L]사용자 onGroup 업데이트 성공")
            }
        }
    }
    
    // MARK: - 멤버 관리 메서드
    // 사용자들의 그룹 멤버십 업데이트
    func updateUsersGroupMemberships(userIDs: [String], groupID: String, groupName: String) {
        for userID in userIDs {
            fsDB.collection("users").document(userID).updateData([
                "joinedGroups": FieldValue.arrayUnion([groupName]),
                "joinedGroupUIDs": FieldValue.arrayUnion([groupID])
            ]) { error in
                if let error = error {
                    print("[E]사용자 \(userID)의 그룹 멤버십 업데이트 실패: \(error.localizedDescription)")
                } else {
                    print("[L]사용자 \(userID)의 그룹 멤버십 업데이트 성공")
                }
            }
        }
    }
    
    // 그룹 멤버 목록 가져오기
    func fetchGroupMembers(groupID: String) {
        // 그룹 문서 가져오기
        fsDB.collection("groups").document(groupID).getDocument { snapshot, error in
            if let error = error {
                print("[E]그룹 정보 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            if let document = snapshot, document.exists {
                // 멤버 배열 추출
                if let members = document.data()?["member"] as? [String] {
                    DispatchQueue.main.async {
                        self.groupMembers = members
                        print("[L]그룹 멤버 가져오기 성공: \(members.count)명")
                    }
                }
            }
        }
    }
    
    // 해당 그룹의 멤버 목록 반환
    func getGroupMembers(groupID: String) -> [String] {
        if groupID == currentGroup?.groupID {
            return groupMembers
        } else {
            // 캐시된 그룹이 아니면 빈 배열 반환 (비동기적으로 fetchGroupMembers 호출 필요)
            return []
        }
    }
    
    // ---------------------
    
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
        fsDB.collection("userSchedules")
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
                    if let schedule = try? document.data(as: PDUserSchedule.self) {
                        for timeSlot in schedule.schedules {
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
    
    // 그룹 데이터 초기화 (로그아웃 시 사용)
    func resetGroupData() {
        self.groups = []
        self.currentGroup = nil
        self.groupMembers = []
        print("[L] GroupViewModel 초기화 완료")
    }
}
