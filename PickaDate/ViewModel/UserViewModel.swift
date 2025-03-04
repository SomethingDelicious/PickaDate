//
//  UserViewModel.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/4/25.
//

import SwiftUI
import FirebaseFirestore

class UserViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var userData: [PDUser] = []
    @Published var userSchedule: [PDUserSchedule] = []
    
    
    // 유저 데이터 가져오기
    func fetchUsers() {
        fsDB.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                print("[L]데이터 가져오기 성공")
                self.userData = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDUser.self)
                } ?? []
            }
        }
    }
}
