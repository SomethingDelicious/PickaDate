//
//  SettingView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/18/25.
//

import SwiftUI

struct SettingView: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        NavigationView {
            List {
                // 로그아웃 버튼을 위한 섹션
                Section {
                    // 로그아웃 버튼 (아직 기능 미구현)
                    Button("로그아웃") {
                        authService.signOut()
                    }
                    .foregroundColor(.red) // 경고성 액션이므로 빨간색으로 표시
                } header: {
                    Text("계정")
                }
            }
            .navigationTitle("설정")
        }
    }
}

