//
//  ContentView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/2/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        Group  {
            if authService.user != nil {
                // 로그인된 상태 = 홈 화면 표시
                HomeView()
            } else {
                // 비로그인 상태 = 로그인 화면 표시
                LoginView()
            }
        }
    }
}

