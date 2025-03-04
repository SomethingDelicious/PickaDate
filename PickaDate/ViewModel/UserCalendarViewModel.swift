//
//  UserCalendarViewModel.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/4/25.
//

import SwiftUI
import FirebaseFirestore

class UserCalendarViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var userData: [PDUser] = []
    @Published var userSchedule: [PDUserSchedule] = []
    
    func fetchUserSchedules() {
        fsDB.collection("userSchedules").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.userSchedule = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDUserSchedule.self)
                } ?? []
            }
        }
    }
    
    func addUserSchedule(userID: String, name: String, content: String, groupIDs: [String], schedule: [UserTimeSlot], userScheduleColor: String) {
        let scheduleData = schedule.map { slot in
            return [
                "startTime": slot.startTime,
                "endTime": slot.endTime,
                "isAllDay": slot.isAllDay
            ] as [String: Any]
        }
        
        let userSchedule: [String: Any] = [
            "userID": userID,
            "name": name,
            "content": content,
            "createdAt": FieldValue.serverTimestamp(),
            "schedule": scheduleData,
            "groupIDs": groupIDs,
            "userScheduleColor" : userScheduleColor
        ]
        
        fsDB.collection("userSchedule").document().setData(userSchedule) { error in
            if let error = error {
                print("[E]추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]문서 추가 성공")
                self.fetchUserSchedules()
            }
        }
    }
    func updateUserSchedule(scheduleID: String, userID: String, name: String, content: String, groupIDs: [String], schedule: [UserTimeSlot], userScheduleColor: String) {
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
            "groupIDs": groupIDs,
            "userScheduleColor": userScheduleColor
        ]
        
        fsDB.collection("userSchedule").document(scheduleID).updateData(updatedSchedule) { error in
            if let error = error {
                print("[E] 업데이트 실패: \(error.localizedDescription)")
            } else {
                print("[L] 문서 업데이트 성공")
                self.fetchUserSchedules() // 데이터 새로고침
            }
        }
    }
    
    
    func deleteUserSchedule(scheduleID: String) {
        fsDB.collection("userSchedule").document(scheduleID).delete { error in
            if let error = error {
                print("[E]삭제 실패: \(error.localizedDescription)")
            } else {
                print("[L]삭제 성공")
                self.fetchUserSchedules()
            }
        }
    }
}
