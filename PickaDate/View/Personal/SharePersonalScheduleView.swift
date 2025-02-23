//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct SharePersonalScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FirestoreViewModel()
    
    let user: User
    let schedule: PersonalSchedule
    
    let colors: [String] = ["red", "orange", "yellow", "green", "blue", "purple", "brown"]
    
    let colorMap: [String: Color] = [
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "blue": .blue,
        "purple": .purple,
        "brown": .brown
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                Text("사용자 정보")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 5)
                
                HStack {
                    Text("ID: ")
                        .font(.headline)
                    Text(user.userID)
                }
                
                HStack {
                    Text("가입 날짜: ")
                        .font(.headline)
                    Text(formattedDate(user.registeredAt))
                }
                
                VStack(alignment: .leading) {
                    Text("가입한 그룹: ")
                        .font(.headline)
                    ForEach(user.joinGroup, id: \.self) { group in
                        Text(group)
                            .padding(5)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
}
