//
//  GroupCalendarViewModel.swift
//  PickaDate
//
//  Created by NoelMacMini on 2/23/25.
//

import SwiftUI
import FirebaseFirestore

class GroupCalendarViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var userData: [PDUser] = []
    @Published var personalSchedule: [PDPersonalSchedule] = []
    @Published var groupSchedule: [PDGroupSchedule] = []
    
    
    //테스트용
    func fetchUsers() {
        fsDB.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.userData = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDUser.self)
                } ?? []
            }
        }
    }
    
    //테스트용
    func addUser(text: String, num: Int) {
        let userData: [String: Any] = [
            "text": text,
            "num": num,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        fsDB.collection("userTestData").document(text).setData(userData) { error in
            if let error = error {
                print("[E]추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]문서 추가 성공")
                self.fetchUsers()
            }
        }
    }
    
    //테스트용
    func deleteUser(userID: String) {
        fsDB.collection("userTestData").document(userID).delete { error in
            if let error = error {
                print("[E]삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]삭제 성공")
                self.fetchUsers()
            }
        }
    }
    func fetchPersonalSchedules() {
        fsDB.collection("personalSchedule").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.personalSchedule = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDPersonalSchedule.self)
                } ?? []
            }
        }
    }
    func fetchGroupSchedules() {
        fsDB.collection("groupSchedule").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.groupSchedule = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDGroupSchedule.self)
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
    
    func deletePersonalSchedule(userID: String) {
        fsDB.collection("personalSchedule").document(userID).delete { error in
            if let error = error {
                print("[E]삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]삭제 성공")
                self.fetchPersonalSchedules()
            }
        }
    }
}
