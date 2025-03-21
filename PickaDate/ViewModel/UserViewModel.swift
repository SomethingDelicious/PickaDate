//
//  UserViewModel.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/4/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class UserViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var currentUser: PDUser?
    @Published var userSchedules: [PDUserSchedule] = []
    
    enum UserError: Error, LocalizedError {
        case userNotFound
        case invalidUserData
        
        var errorDescription: String? {
            switch self {
            case .userNotFound:
                return "사용자 정보를 찾을 수 없습니다."
            case .invalidUserData:
                return "사용자 정보 구조가 올바르지 않습니다."
            }
        }
    }
    
    // 로그인된 유저 데이터 가져오기
    func fetchCurrentUser() async throws {
        // Auth에서 현재 로그인된 사용자의 uid 가져오기
        guard let uid = Auth.auth().currentUser?.uid else {
            throw UserError.userNotFound
        }
        
        // 해당 uid의 사용자 문서 가져오기
        let docSnapshot = try await fsDB.collection("users").document(uid).getDocument()
        
        guard docSnapshot.exists else {
            throw UserError.userNotFound
        }
        
        // 사용자 정보 파싱
        guard let user = try? docSnapshot.data(as: PDUser.self) else {
            throw UserError.invalidUserData
        }
        
        // 메인 스레드에서 UI 업데이트
        await MainActor.run {
            self.currentUser = user
            print("[L]사용자 정보 가져오기 성공")
            // 사용자 정보를 가져온 후 바로 일정 정보도 가져오기
            self.fetchUserSchedules()
        }
    }
    
    // 사용자 일정 가져오기
     func fetchUserSchedules() {
         guard let userID = currentUser?.userID else {
             print("[E] 현재 로그인된 사용자가 없습니다.")
             return
         }
         
         fsDB.collection("userSchedules")
             .whereField("userID", isEqualTo: userID)
             .getDocuments { snapshot, error in
                 if let error = error {
                     print("[E] 데이터 가져오기 실패: \(error.localizedDescription)")
                     return
                 }
                 
                 DispatchQueue.main.async {
                     self.userSchedules = snapshot?.documents.compactMap { doc in
                         try? doc.data(as: PDUserSchedule.self)
                     } ?? []
                     print("[L] 사용자 일정 가져오기 성공: \(self.userSchedules.count)개")
                 }
             }
     }
    
    // 유저스케쥴 추가하기
     func addUserSchedule(title: String, content: String, groupIDs: [String], schedule: [UserTimeSlot], userScheduleColor: String) {
         guard let userID = currentUser?.userID else {
             print("[E] 현재 로그인된 사용자가 없습니다.")
             return
         }
         
         let scheduleData = schedule.map { slot in
             return [
                 "startTime": slot.startTime,
                 "endTime": slot.endTime,
                 "isAllDay": slot.isAllDay
             ] as [String: Any]
         }
         
         let userSchedule: [String: Any] = [
             "userID": userID,
             "title": title,
             "content": content,
             "createdAt": FieldValue.serverTimestamp(),
             "schedule": scheduleData,
             "groupIDs": groupIDs,
             "userScheduleColor" : userScheduleColor
         ]
         
         fsDB.collection("userSchedules").document().setData(userSchedule) { error in
             if let error = error {
                 print("[E] 추가 실패: \(error.localizedDescription)")
             } else {
                 print("[L] 문서 추가 성공")
                 self.fetchUserSchedules()
             }
         }
     }
     
     // 유저스케쥴 업데이트하기
     func updateUserSchedule(scheduleID: String, title: String, content: String, groupIDs: [String], schedule: [UserTimeSlot], userScheduleColor: String) {
         guard let userID = currentUser?.userID else {
             print("[E] 현재 로그인된 사용자가 없습니다.")
             return
         }
         
         let scheduleData = schedule.map { slot in
             return [
                 "startTime": slot.startTime,
                 "endTime": slot.endTime,
                 "isAllDay": slot.isAllDay
             ] as [String: Any]
         }
         
         let updatedSchedule: [String: Any] = [
             "userID": userID,
             "title": title,
             "content": content,
             "updatedAt": FieldValue.serverTimestamp(),
             "schedule": scheduleData,
             "groupIDs": groupIDs,
             "userScheduleColor": userScheduleColor
         ]
         
         fsDB.collection("userSchedules").document(scheduleID).updateData(updatedSchedule) { error in
             if let error = error {
                 print("[E] 업데이트 실패: \(error.localizedDescription)")
             } else {
                 print("[L] 문서 업데이트 성공")
                 self.fetchUserSchedules() // 데이터 새로고침
             }
         }
     }
     
     // 유저스케쥴 삭제하기
     func deleteUserSchedule(scheduleID: String) {
         fsDB.collection("userSchedules").document(scheduleID).delete { error in
             if let error = error {
                 print("[E] 삭제 실패: \(error.localizedDescription)")
             } else {
                 print("[L] 삭제 성공")
                 self.fetchUserSchedules()
             }
         }
     }
    
    // 사용자 데이터 초기화 (로그아웃 시 사용)
    func resetUserData() {
        self.currentUser = nil
        self.userSchedules = []
        print("[L] UserViewModel 초기화 완료")
    }

 }
