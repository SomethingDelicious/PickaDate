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
    @Published var currentUserID: String = ""
    
    // ViewModel 참조를 저장할 변수들 추가
    weak var userViewModel: UserViewModel?
    weak var groupViewModel: GroupViewModel?
    
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
    
    enum AuthError: Error, LocalizedError {
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
    
    // 회원가입
    func signUp(email: String, fullName: String, userName: String, password: String) async throws {
        do {
            // 1. Firebase Auth로 사용자 생성
            let authResult = try await auth.createUser(withEmail: email, password: password)
            let uid = authResult.user.uid
            
            // 2. Firestore에 추가 사용자 정보 저장
            try await db.collection("users").document(uid).setData([
                "email": email,
                "fullName": fullName,
                "userName": userName,
                "registeredAt": Date(),
                "joinedGroups": [],
                "joinedGroupUIDs": [],
                "onGroup": ""
            ])
            
            // 3. 현재 사용자 설정
            self.user = authResult.user
            self.currentUserID = uid
            
        } catch {
            throw error
        }
    }
    
    // 로그인
    func signIn(email: String, password: String) async throws {
        // Firebase Authentication에 로그인 요청
        let authResult = try await auth.signIn(withEmail: email, password: password)
        self.user = authResult.user
        self.currentUserID = authResult.user.uid // uid 저장
        
        // 로그인 성공 후 사용자 정보 가져오기
        let uid = authResult.user.uid
        let userDoc = try await db.collection("users").document(uid).getDocument()
        
        guard userDoc.exists else {
            throw AuthError.userNotFound
        }
    }
    
    // 로그아웃
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
            self.currentUserID = ""
            
            // ViewModel 초기화 호출
            userViewModel?.resetUserData()
            groupViewModel?.resetGroupData()
            
            print("[L] 로그아웃 성공 및 ViewModel 초기화 완료")
            
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    

    
    
    
}
