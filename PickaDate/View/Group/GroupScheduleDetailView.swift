//
//  GroupScheduleDetailView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/28/25.
//

import SwiftUI

struct GroupScheduleDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = GroupScheduleViewModel()
    
    let schedule: GroupSchedule
    let userID: String
    
    @State private var isParticipating: Bool
    @State private var showingConfirmAlert = false
    @State private var showingDeleteAlert = false
    
    init(schedule: GroupSchedule, userID: String) {
        self.schedule = schedule
        self.userID = userID
        self._isParticipating = State(initialValue: schedule.participants.contains(userID))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 일정 헤더
                VStack(alignment: .leading, spacing: 10) {
                    Text(schedule.title)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(schedule.color)
                    
                    Text(schedule.content)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(schedule.color.opacity(0.1))
                .cornerRadius(12)
                
                // 일정 정보
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(schedule.schedule, id: \.startTime) { timeSlot in
                        HStack(alignment: .top) {
                            Image(systemName: "clock")
                                .foregroundColor(schedule.color)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading) {
                                if timeSlot.isAllDay {
                                    Text("\(formatDate(timeSlot.startTime)) (종일)")
                                } else {
                                    Text("\(formatDate(timeSlot.startTime))")
                                    Text("\(formatTime(timeSlot.startTime)) - \(formatTime(timeSlot.endTime))")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "person.text.rectangle")
                            .foregroundColor(schedule.color)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text("작성자: \(schedule.creator)")
                            Text("작성일: \(formatDateTime(schedule.createdAt))")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        Image(systemName: "tag")
                            .foregroundColor(schedule.color)
                            .frame(width: 24)
                        
                        Text(schedule.status == .planned ? "제안됨" : "확정됨")
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(schedule.status == .planned ? Color.orange.opacity(0.2) : Color.green.opacity(0.2))
                            .foregroundColor(schedule.status == .planned ? .orange : .green)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                // 참여 여부 선택 (확정된 일정이거나 제안 일정일 때)
                VStack(alignment: .leading, spacing: 10) {
                    Text("참여 여부")
                        .font(.headline)
                    
                    if schedule.checkedMembers.contains(userID) {
                        Picker("참여 상태", selection: $isParticipating) {
                            Text("참여").tag(true)
                            Text("불참").tag(false)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: isParticipating) { newValue in
                            updateParticipationStatus()
                        }
                    } else {
                        HStack {
                            Button(action: {
                                isParticipating = true
                                updateParticipationStatus()
                            }) {
                                Text("참여하기")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                isParticipating = false
                                updateParticipationStatus()
                            }) {
                                Text("불참하기")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // 참가자 목록
                VStack(alignment: .leading, spacing: 10) {
                    Text("참가자 목록")
                        .font(.headline)
                    
                    if schedule.participants.isEmpty {
                        Text("아직 참가자가 없습니다.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(schedule.participants, id: \.self) { participant in
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.green)
                                Text(participant)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                
                // 불참자 목록
                VStack(alignment: .leading, spacing: 10) {
                    Text("불참자 목록")
                        .font(.headline)
                    
                    if schedule.nonParticipants.isEmpty {
                        Text("아직 불참자가 없습니다.")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(schedule.nonParticipants, id: \.self) { nonParticipant in
                            HStack {
                                Image(systemName: "person.fill.xmark")
                                    .foregroundColor(.red)
                                Text(nonParticipant)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                
                // 관리자 기능 (작성자인 경우)
                if schedule.creator == userID {
                    VStack {
                        // 제안 일정을 확정으로 변경 (상태가 planned일 때)
                        if schedule.status == .planned {
                            Button(action: {
                                showingConfirmAlert = true
                            }) {
                                Text("일정 확정하기")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            .alert(isPresented: $showingConfirmAlert) {
                                Alert(
                                    title: Text("일정 확정"),
                                    message: Text("이 일정을 확정하시겠습니까? 참여 의사를 밝힌 멤버들이 참가자로 설정됩니다."),
                                    primaryButton: .default(Text("확정")) {
                                        confirmSchedule()
                                    },
                                    secondaryButton: .cancel(Text("취소"))
                                )
                            }
                        }
                        
                        // 일정 삭제
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Text("일정 삭제하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            Alert(
                                title: Text("일정 삭제"),
                                message: Text("이 일정을 삭제하시겠습니까? 삭제된 일정은 복구할 수 없습니다."),
                                primaryButton: .destructive(Text("삭제")) {
                                    deleteSchedule()
                                },
                                secondaryButton: .cancel(Text("취소"))
                            )
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("일정 상세")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 참여 상태 업데이트
    private func updateParticipationStatus() {
        guard let scheduleID = schedule.id else { return }
        
        viewModel.updateMemberStatus(
            scheduleID: scheduleID,
            memberID: userID,
            isParticipating: isParticipating
        ) { success in
            if success {
                // 업데이트 성공 시 필요한 작업
            }
        }
    }
    
    // 일정 확정
    private func confirmSchedule() {
        guard let scheduleID = schedule.id else { return }
        
        viewModel.confirmGroupSchedule(
            scheduleID: scheduleID,
            participants: schedule.participants,
            nonParticipants: schedule.nonParticipants
        ) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // 일정 삭제
    private func deleteSchedule() {
        guard let scheduleID = schedule.id else { return }
        
        viewModel.deleteGroupSchedule(scheduleID: scheduleID) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // 날짜 및 시간 형식 지정 헬퍼 함수
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: date)
    }
}
    
    
