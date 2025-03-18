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
        }
    }
}
