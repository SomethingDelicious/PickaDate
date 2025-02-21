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
    @Published var userTestData: [UserTest] = []
    
    func fetchUsers() {
        fsDB.collection("userTestData").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.userTestData = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: UserTest.self)
                } ?? []
            }
        }
    }

    func addUser(text: String, num: Int) {
        let userData: [String: Any] = [
            "text": text,
            "num": num,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        fsDB.collection("userTestData").addDocument(data: userData) { error in
            if let error = error {
                print("[E]추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]문서 추가 성공")
                self.fetchUsers()
            }
        }
    }
    
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

