//
//  GroupScheduleListView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/28/25.
//

import SwiftUI

struct GroupScheduleListView: View {
    @StateObject private var viewModel = GroupScheduleViewModel()
    
    let groupID: String
    let userID: String
    
    @State private var isShowingProposeSheet = false
    
    var body: some View {
        List {
            // 제안된 일정 섹션
            Section(header: Text("제안된 일정").font(.headline)) {
                let proposedSchedules = viewModel.groupSchedule
                    .filter { $0.status == .planned }
                    .sorted(by: { $0.createdAt > $1.createdAt })
                
                if proposedSchedules.isEmpty {
                    Text("제안된 일정이 없습니다")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.vertical, 8)
                } else {
                    ForEach(proposedSchedules) { schedule in
                        NavigationLink(destination: GroupScheduleDetailView(schedule: schedule, userID: userID)) {
                            ScheduleRow(schedule: schedule)
                        }
                    }
                }
            }
            
            // 확정된 일정 섹션
            Section(header: Text("확정된 일정").font(.headline)) {
                let confirmedSchedules = viewModel.groupSchedule
                    .filter { $0.status == .confirmed }
                    .sorted(by: { $0.createdAt > $1.createdAt })
                
                if confirmedSchedules.isEmpty {
                    Text("확정된 일정이 없습니다")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.vertical, 8)
                } else {
                    ForEach(confirmedSchedules) { schedule in
                        NavigationLink(destination: GroupScheduleDetailView(schedule: schedule, userID: userID)) {
                            ScheduleRow(schedule: schedule)
                        }
                    }
                }
            }
        }
        .navigationTitle("\(groupID) 일정")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isShowingProposeSheet = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isShowingProposeSheet, onDismiss: {
            viewModel.fetchGroupSchedules(groupID: groupID)
        }) {
            ProposeGroupScheduleView(userID: userID, groupID: groupID)
        }
        .onAppear {
            viewModel.fetchGroupSchedules(groupID: groupID)
        }
    }
}

// 일정 행 컴포넌트
struct ScheduleRow: View {
    let schedule: GroupSchedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(schedule.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if !schedule.schedule.isEmpty, let firstSlot = schedule.schedule.first {
                Text(formatDateRange(startTime: firstSlot.startTime, endTime: firstSlot.endTime, isAllDay: firstSlot.isAllDay))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(schedule.participants.count)명 참여", systemImage: "person.3")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(schedule.status == .planned ? "제안됨" : "확정됨")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(schedule.status == .planned ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                    .foregroundColor(schedule.status == .planned ? .orange : .green)
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
        .listRowBackground(schedule.color.opacity(0.1))
    }
    
    // 날짜 범위 포맷팅
    private func formatDateRange(startTime: Date, endTime: Date, isAllDay: Bool) -> String {
        let formatter = DateFormatter()
        
        if isAllDay {
            formatter.dateFormat = "yyyy년 M월 d일"
            return "\(formatter.string(from: startTime)) (종일)"
        } else {
            formatter.dateFormat = "yyyy년 M월 d일"
            let dateStr = formatter.string(from: startTime)
            
            formatter.dateFormat = "HH:mm"
            let startTimeStr = formatter.string(from: startTime)
            let endTimeStr = formatter.string(from: endTime)
            
            return "\(dateStr) \(startTimeStr) - \(endTimeStr)"
        }
    }
}

#Preview {
    GroupScheduleListView(groupID: "group123", userID: "user123")
}

