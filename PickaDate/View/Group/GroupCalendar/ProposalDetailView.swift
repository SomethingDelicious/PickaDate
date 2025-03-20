//
//  ProposalDetailView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/20/25.
//

import SwiftUI

struct ProposalDetailView: View {
    @EnvironmentObject private var calendarViewModel: GroupCalendarViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var groupViewModel: GroupViewModel
    
    // 제안 정보
    let proposal: GroupScheduleProposal
    
    // 투표한 선택지 인덱스
    @State private var selectedOptionIndex: Int? = nil
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 제목 및 정보 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text(proposal.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("제안자: \(getUserName(userID: proposal.creator))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("작성일: \(formatDateTime(proposal.createdAt))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    StatusBadge(status: proposal.status)
                        .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 내용 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("내용")
                        .font(.headline)
                    
                    Text(proposal.content)
                        .padding()
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(8)
                }
                .padding()
                
                // 일정 옵션 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("제안 일정")
                        .font(.headline)
                    
                    ForEach(Array(proposal.schedule.enumerated()), id: \.offset) { index, timeSlot in
                        ScheduleOptionView(
                            index: index,
                            timeSlot: timeSlot,
                            isSelected: selectedOptionIndex == index,
                            color: colorMap[proposal.groupColor, default: .blue],
                            onTap: {
                                if proposal.status == .pending {
                                    selectedOptionIndex = index
                                }
                            }
                        )
                    }
                }
                .padding()
                
                // 투표 결과 섹션
                VStack(alignment: .leading, spacing: 8) {
                    Text("투표 현황")
                        .font(.headline)
                    
                    // 투표 결과 집계
                    // (실제 구현에서는 여기에 투표 결과 표시)
                    Text("투표한 인원: \(proposal.votes.count)명")
                        .foregroundColor(.gray)
                }
                .padding()
                
                // 버튼 섹션
                if proposal.status == .pending {
                    VStack(spacing: 16) {
                        Button(action: submitVote) {
                            Text("투표하기")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedOptionIndex != nil ? Color.blue : Color.gray)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(selectedOptionIndex == nil)
                        
                        // 제안자인 경우 추가 버튼
                        if isProposalCreator {
                            Button(action: confirmSchedule) {
                                Text("일정 확정하기")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: cancelProposal) {
                                Text("제안 취소하기")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationTitle("일정 제안 상세")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 이미 투표한 경우 선택한 인덱스 가져오기
            loadUserVote()
        }
    }
    
    // MARK: - Helper Methods
    
    // 사용자 이름 가져오기
    private func getUserName(userID: String) -> String {
        // 실제 구현에서는 사용자 이름을 가져오는 로직 추가
        // 지금은 간단하게 userID로 반환
        return userID
    }
    
    // 날짜 포맷팅
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: date)
    }
    
    // 현재 사용자가 제안자인지 확인
    private var isProposalCreator: Bool {
        return userViewModel.currentUser?.userID == proposal.creator
    }
    
    // 사용자 투표 로드
    private func loadUserVote() {
        guard let userID = userViewModel.currentUser?.userID else { return }
        
        if let voteIndex = proposal.votes[userID], let index = Int(voteIndex) {
            selectedOptionIndex = index
        }
    }
    
    // 투표 제출
    private func submitVote() {
        guard let userID = userViewModel.currentUser?.userID,
              let index = selectedOptionIndex else { return }
        
        // 실제 구현에서는 투표 로직 추가
        print("사용자 \(userID)가 옵션 \(index)에 투표")
        
        // 여기에 투표 업데이트 로직 추가
    }
    
    // 일정 확정
    private func confirmSchedule() {
        // 실제 구현에서는 일정 확정 로직 추가
        print("일정 확정")
    }
    
    // 제안 취소
    private func cancelProposal() {
        // 실제 구현에서는 제안 취소 로직 추가
        print("제안 취소")
    }
}

// 일정 옵션 뷰
struct ScheduleOptionView: View {
    let index: Int
    let timeSlot: TimeSlotGroup
    let isSelected: Bool
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("옵션 \(index + 1)")
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(formatDate(timeSlot.startTime))
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                        if timeSlot.isAllDay {
                            Text("종일")
                        } else {
                            Text("\(formatTime(timeSlot.startTime)) ~ \(formatTime(timeSlot.endTime))")
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? color : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? color : Color.gray.opacity(0.5), lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    // 날짜 포맷팅
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    // 시간 포맷팅
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
