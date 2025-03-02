//
//  FirestoreViewModel.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

class FirestoreViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var userTestData: [PDUserTest] = []
    @Published var personalSchedule: [PDPersonalSchedule] = []
    
    
    //테스트용
    func fetchUsers() {
        fsDB.collection("userTestData").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.userTestData = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDUserTest.self)
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
    func deleteUser(userId: String) {
        fsDB.collection("userTestData").document(userId).delete { error in
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
    
    func addPersonalSchedule(userID: String, name: String, content: String, groupID: [String], schedule: [TimeSlotPersonal], personalColor: String) {
        let scheduleData = schedule.map { slot in
            return [
                "startTime": slot.startTime,
                "endTime": slot.endTime,
                "isAllDay": slot.isAllDay
            ] as [String: Any]
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
    func updatePersonalSchedule(scheduleID: String, userID: String, name: String, content: String, groupID: [String], schedule: [TimeSlotPersonal], personalColor: String) {
        let scheduleData = schedule.map { slot in
            return [
                "startTime": slot.startTime,
                "endTime": slot.endTime,
                "isAllDay": slot.isAllDay
            ] as [String: Any]
            
        }
        
        let updatedSchedule: [String: Any] = [
            "userID": userID,   // 기존 데이터와 일관성 유지
            "name": name,
            "content": content,
            "updatedAt": FieldValue.serverTimestamp(), // 수정된 시간 기록
            "schedule": scheduleData,
            "groupID": groupID,
            "personalColor": personalColor
        ]
        
        fsDB.collection("personalSchedule").document(scheduleID).updateData(updatedSchedule) { error in
            if let error = error {
                print("[E] 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("[L] 문서 업데이트 성공")
                self.fetchPersonalSchedules() // 데이터 새로고침
            }
        }
    }
    
    
    func deletePersonalSchedule(scheduleID: String) {
        fsDB.collection("personalSchedule").document(scheduleID).delete { error in
            if let error = error {
                print("[E]삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]삭제 성공")
                self.fetchPersonalSchedules()
            }
        }
    }
    
    //    func updateUser(userId: String, newName: String) {
    //        fsDB.collection("users").document(userId).updateData([
    //            "text": newName
    //        ]) { error in
    //            if let error = error {
    //                print("업데이트 실패: \(error.localizedDescription)")
    //            } else {
    //                print("업데이트 성공")
    //            }
    //        }
    //    }
}

