//
//  GroupDateView.swift
//  PickaDate
//
//  Created by NoelMacMini on 2/22/25.
//

import SwiftUI

struct GroupDateView: View {
    // MARK: - Properties
    @State private var selectedDate = Date() // 선택된 날짜 저장
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                // 캘린더 섹션
                DatePicker(
                    "날짜 선택",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical) // 달력 스타일
                .padding()
                
                // 선택된 날짜 표시
                Text("선택된 날짜: \(formattedDate(selectedDate))")
                    .font(.headline)
                
                // 일정 목록 섹션 (더미 데이터로 우선 구현하기)
                List {
                    ForEach(1...3, id: \.self) { index in
                        Text("예시 일정 \(index)")
                    }
                }
            }
            .navigationTitle("그룹 일정")
        }
    }
    
    // MARK: - Methods
    // Date 타입을 받아서 형식화된 문자열로 변환하는 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter() // 날짜 형식을 지정하는 포메터 생성
        formatter.dateFormat = "yyyy년 MM월 dd일" // 날짜 형식을 지정
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        return formatter.string(from: date) // 날짜를 문자열로 변환하여 번환
    }
}

// MARK: - Preview
#Preview {
    GroupDateView()
}
