//
//  GroupViewModel.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI
import FirebaseFirestore

class GroupViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
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
    func addGroup(groupName: String, leader: String, member: [String]) {
        let groupID = UUID().uuidString
        let groupData: [String: Any] = [
            "groupID": groupID,
            "groupName": groupName,
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
}
