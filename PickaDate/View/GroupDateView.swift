//
//  GroupDateView.swift
//  PickaDate
//
//  Created by NoelMacMini on 2/22/25.
//

import SwiftUI

struct GroupDateView: View {
    // MARK: - Properties
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                // TODO: 캘린더 섹션 구현하기
                Text("캘린더 영역")
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .background(Color.gray.opacity(0.1))
                
                // TODO: 일정 목록 섹션 구현하기
                List {
                    Text("일정 목록 영역")
                }
            }
            .navigationTitle("그룹 일정")
        }
    }
}

// MARK: - Preview
#Preview {
    GroupDateView()
}
