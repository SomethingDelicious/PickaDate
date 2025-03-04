//
//  AuthService.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/2/25.
//

//
import Foundation
import FirebaseAuth
import FirebaseFirestore

// 임시 로그인 기능
@MainActor
class AuthService: ObservableObject {
    @Published var user: User?
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    // 현재 에뮬레이터 사용 여부를 확인하는 속성 추가
    private var isEmulator: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    // 회원가입
    func signUp(userID: String, email: String, userName: String, password: String) async throws {
        do {
            // 1. Firebase Auth로 사용자 생성
            let authResult = try await auth.createUser(withEmail: email, password: password)
            
            // 2. Firestore에 추가 사용자 정보 저장
            try await db.collection("users").document(authResult.user.uid).setData([
                "userID": userID,
                "email": email,
                "userName": userName,
                "registeredAt": Date(),
            ])
            
            // 3. 현재 사용자 설정
            self.user = authResult.user
            
        } catch {
            throw error
        }
    }
    
    // 로그인
    func signIn(userID: String, password: String) async throws {
        // 1. userID로 사용자의 이메일 찾기
        let querySnapshot = try await db.collection("users")
            .whereField("userID", isEqualTo: userID)
            .getDocuments()
        
        guard let document = querySnapshot.documents.first,
              let email = document.data()["email"] as? String else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자를 찾을 수 없습니다."])
        }
        
        // 2. 찾은 이메일로 로그인
        let user = try await auth.signIn(withEmail: email, password: password).user
        self.user = user
    }
    
    // 로그아웃
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    
    
}
