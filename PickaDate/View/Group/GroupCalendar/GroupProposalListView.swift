//
//  GroupProposalListView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/20/25.
//

import SwiftUI

struct GroupProposalListView: View {
    // 외부에서 주입 받는 대신 환경 객체로 사용
    @EnvironmentObject private var groupViewModel: GroupViewModel
    @EnvironmentObject private var calendarViewModel: GroupCalendarViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // 제안 목록이 비어있는 경우 처리
                if calendarViewModel.groupProposals.isEmpty {
                    Text("일정 제안이 없습니다.")
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    ForEach(calendarViewModel.groupProposals) { proposal in
                        ProposalRowView(proposal: proposal)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("\(groupViewModel.currentGroup?.groupName ?? "") 일정 제안")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                // 뷰가 나타날 때 해당 그룹의 제안 목록 가져오기
                if let currentGroup = groupViewModel.currentGroup {
                    Task {
                        await calendarViewModel.fetchGroupProposals(for: currentGroup.groupID)
                    }
                }
            }
        }
    }
}


// 제안 행 뷰 (리스트의 각 행)
struct ProposalRowView: View {
    let proposal: GroupScheduleProposal
    
    var body: some View {
        NavigationLink(destination: ProposalDetailView(proposal: proposal)) {
            VStack(alignment: .leading, spacing: 8) {
                Text(proposal.title)
                    .font(.headline)
                
                Text(proposal.content)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.gray)
                
                HStack {
                    // 상태 표시
                    StatusBadge(status: proposal.status)
                    
                    Spacer()
                    
                    // 날짜 정보
                    if let firstDate = proposal.schedules.first?.startTime {
                        Text(formatDate(firstDate))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // 날짜 포맷팅 함수
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
}

// 상태 배지 뷰
struct StatusBadge: View {
    let status: ProposalStatus
    
    var body: some View {
        Text(statusText)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(statusColor)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
    
    // 상태에 따른 텍스트
    private var statusText: String {
        switch status {
        case .pending:
            return "진행 중"
        case .confirmed:
            return "확정됨"
        case .canceled:
            return "취소됨"
        }
    }
    
    // 상태에 따른 색상
    private var statusColor: Color {
        switch status {
        case .pending:
            return .blue
        case .confirmed:
            return .green
        case .canceled:
            return .gray
        }
    }
}
