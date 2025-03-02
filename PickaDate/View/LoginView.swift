//
//  LoginView.swift
//  PickaDate
//
//  Created by 심연아 on 2/22/25.
//

import SwiftUI

// 임시 로그인 화면
struct LoginView: View {
    // MARK: - Properties
    // @State private var email = ""    // 이메일 입력값
    @State private var appId = ""    // 아이디 입력값
    @State private var password = "" // 비밀번호 입력값
    @EnvironmentObject private var authService: AuthService
    
    // 로딩 상태와 에러 처리를 위한 상태 추가
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // 입력 유효성 검사
    private var isValidAppId: Bool {
        appId.count >= 4 // 최소 4자 이상
    }
    private var isValidPassword: Bool {
        password.count >= 6 // 최소 6자 이상
    }
    
    // 전체 입력 유효성 검사
    private var isValidInput: Bool {
        isValidAppId && isValidPassword
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    // 로고나 앱 이름
                    Text("PickaDate")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    //                // 이메일 입력 필드
                    //                TextField("이메일", text: $email)
                    //                    .textFieldStyle(.roundedBorder)
                    //                    .textInputAutocapitalization(.never) // 자동 대문자 비활성화
                    //                    .keyboardType(.emailAddress)              // 이메일 키보드
                    
                    // 아이디 입력 필드
                    TextField("아이디", text: $appId)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never) // 자동 대문자 비활성화
                        .disabled(isLoading)
                    if !isValidAppId && !appId.isEmpty {
                        Text("아이디는 최소 4자 이상이어야 합니다")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // 비밀번호 입력 필드
                    SecureField("비밀번호", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isLoading)
                    if !isValidPassword && !password.isEmpty {
                        Text("비밀번호는 최소 6자 이상이어야 합니다")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // 로그인 버튼
                    Button(action: {
                        Task {
                            await login()
                        }
                    }) {
                        Text("로그인")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidInput ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .disabled(!isValidInput || isLoading)
                    
                    // 회원가입 링크
                    NavigationLink("계정이 없으신가요? 회원가입") {
                        SignUpView()
                    }
                    .padding(.top)
                    .disabled(isLoading)
                }
                .padding()
                
                // 로딩 오버레이
                if isLoading {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                }
            }
            .alert("로그인 오류", isPresented: $showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Methods
    private func login() async {
        isLoading = true
        do {
            try await authService.signIn(appId: appId, password: password)
            // 로그인 성공 시 처리 (예. 메인 화면으로 이동)
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
}


// MARK: - Preview
#Preview {
    LoginView()
}
