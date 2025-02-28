//
//  SharePersonalScheduleView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

struct SharePersonalScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FirestoreViewModel()
    
    let user: User
    let schedule: PersonalSchedule
    
    @State private var selectedGroups: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                
                
                VStack(alignment: .leading) {
                    
                    MultiSelectGroupView(userGroups: user.joinedGroups, selectedGroups: $selectedGroups)
                        .frame(height: 200)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                Spacer()
                if !selectedGroups.isEmpty {
                    Text("선택된 그룹: \(selectedGroups.joined(separator: ", "))")
                        .font(.headline)
                        .padding(.top, 10)
                }
            }
            .padding()
            .navigationBarItems(
                leading: Button("닫기") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    updatePersonalSchedule()
                    presentationMode.wrappedValue.dismiss()
                }
            )


            .onAppear {
                viewModel.fetchUsers()
                viewModel.fetchPersonalSchedules()
                selectedGroups = Set(schedule.groupID)
            }
        }
        .navigationTitle(Text("일정 공유 그룹"))
        .navigationBarTitleDisplayMode(.inline)
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    func updatePersonalSchedule() {
        let updatedGroupIDArray = selectedGroups.isEmpty ? [] : Array(selectedGroups)
        
        guard let scheduleID = schedule.id else {
            print("오류: schedule.id가 nil입니다.")
            return
        }
        viewModel.updatePersonalSchedule(
            scheduleID: scheduleID,
            userID: user.userID,
            name: schedule.name,
            content: schedule.content,
            groupID: updatedGroupIDArray,
            schedule: schedule.schedule,
            personalColor: schedule.personalColor
        )
    }

}
