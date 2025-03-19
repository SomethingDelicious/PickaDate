//
//  ContentView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/2/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @StateObject private var userViewModel = UserViewModel() // 사용자 데이터를 관리할 뷰모델
    
    var body: some View {
        Group  {
            if authService.user != nil {
                // 로그인된 상태 = 홈 화면 표시
                HomeView()
                    .environmentObject(userViewModel) // 사용자 뷰모델을 환경 객체로 전달
            } else {
                // 비로그인 상태 = 로그인 화면 표시
                LoginView()
            }
        }
        .onAppear {
             if authService.user != nil {
                 // 사용자가 로그인 되어 있다면 사용자 정보 가져오기
                 Task {
                     do {
                         try await userViewModel.fetchCurrentUser()
                     } catch {
                         print("[E] 사용자 정보 가져오기 실패: \(error.localizedDescription)")
                     }
                         
                 }
             }
         }
    }
}

