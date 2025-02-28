//
//  GroupProposalDetailView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupProposalDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = GroupProposalViewModel()

    let proposal: GroupScheduleProposal
    // 실제 앱에서는 현재 사용자 ID를 가져오는 로직 필요
    let currentUserID = "현재 사용자 ID"

    @State private var selectedProposalID: String?
    @State private var showingConfirmAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 제안 기본 정보
                VStack(alignment: .leading, spacing: 8) {
                    Text(proposal.title)
                        .font(.title)
                        .fontWeight(.bold)

                    Text(proposal.description)
                        .font(.body)

                    HStack {
                        Text("제안자: \(proposal.createdBy)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Spacer()

                        Text(formattedDate(proposal.createdAt))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // 제안 상태
                    HStack {
                        Text("상태:")
                            .font(.subheadline)

                        Text(statusText(proposal.status))
                            .font(.subheadline)
                            .foregroundColor(statusColor(proposal.status))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(statusColor(proposal.status).opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                // 제안 후보 목록
                Text("일정 후보")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top, 8)

                ForEach(proposal.proposals, id: \.id) { proposalOption in
                    ProposalOptionCard(
                        proposal: proposalOption,
                        isSelected: selectedProposalID == proposalOption.id,
                        voteCount: proposalOption.votes.count,
                        hasVoted: proposalOption.votes.contains(currentUserID),
                        isConfirmable: proposal.status == .pending,
                        onVote: {
                            viewModel.voteForProposal(
                                proposalID: proposal.proposalID,
                                optionID: proposalOption.id,
                                userID: currentUserID
                            )
                        },
                        onSelect: {
                            selectedProposalID = proposalOption.id
                        }
                    )
                }

                // 확정 버튼 (진행 중인 제안일 경우에만 표시)
                if proposal.status == .pending && selectedProposalID != nil {
                    Button(action: {
                        showingConfirmAlert = true
                    }) {
                        Text("이 일정으로 확정하기")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()
                    .alert(isPresented: $showingConfirmAlert) {
                        Alert(
                            title: Text("일정 확정"),
                            message: Text("선택한 날짜로 일정을 확정하시겠습니까?"),
                            primaryButton: .destructive(Text("확정")) {
                                confirmProposal()
                            },
                            secondaryButton: .cancel(Text("취소"))
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("제안 상세")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 상세 데이터 업데이트
            viewModel.fetchGroupProposals(for: proposal.groupID)
        }
    }

    // 선택한 제안을 확정하는 함수
    private func confirmProposal() {
        guard let selectedID = selectedProposalID else { return }

        // 먼저 제안 상태를 확정으로 변경
        viewModel.updateProposalStatus(proposalID: proposal.proposalID, status: .confirmed)

        // 이후 추가 작업 (예: 확정된 일정을 그룹 일정으로 변환)
        // 이 부분은 다음 단계에서 구현할 수 있습니다
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm"
        return formatter.string(from: date)
    }

    private func statusText(_ status: ProposalStatus) -> String {
        switch status {
        case .pending:
            return "진행 중"
        case .confirmed:
            return "확정됨"
        case .canceled:
            return "취소됨"
        }
    }

    private func statusColor(_ status: ProposalStatus) -> Color {
        switch status {
        case .pending:
            return .blue
        case .confirmed:
            return .green
        case .canceled:
            return .red
        }
    }
}

// 각 제안 후보 카드
struct ProposalOptionCard: View {
    let proposal: Proposal
    let isSelected: Bool
    let voteCount: Int
    let hasVoted: Bool
    let isConfirmable: Bool
    let onVote: () -> Void
    let onSelect: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목 및 선택 상태
            HStack {
                Text(proposal.title)
                    .font(.headline)
                Spacer()
                if isConfirmable {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isSelected ? .blue : .gray)
                        .font(.title2)
                        .onTapGesture {
                            onSelect()
                        }
                }
            }

            // 날짜 목록
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(proposal.dates, id: \.self) { date in
                        Text(formattedDate(date))
                            .font(.subheadline)
                            .padding(6)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
            }

            // 투표 상태
            HStack {
                Text("투표 수: \(voteCount)명")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                if isConfirmable {
                    Button(action: onVote) {
                        Text(hasVoted ? "투표 취소" : "투표하기")
                            .font(.subheadline)
                            .foregroundColor(hasVoted ? .red : .blue)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .padding(.vertical, 4)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
