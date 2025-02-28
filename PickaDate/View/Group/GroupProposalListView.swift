//
//  GroupProposalListView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore

struct GroupProposalListView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = GroupProposalViewModel()

    let groupID: String

    var body: some View {
        List {
            // 진행 중인 제안
            Section(header: Text("진행 중인 제안").font(.headline)) {
                ForEach(viewModel.groupProposals.filter { $0.status == .pending }) { proposal in
                    NavigationLink(destination: GroupProposalDetailView(proposal: proposal)) {
                        ProposalRow(proposal: proposal)
                    }
                }

                if viewModel.groupProposals.filter({ $0.status == .pending }).isEmpty {
                    Text("진행 중인 제안이 없습니다")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.vertical, 8)
                }
            }

            // 확정된 제안
            Section(header: Text("확정된 제안").font(.headline)) {
                ForEach(viewModel.groupProposals.filter { $0.status == .confirmed }) { proposal in
                    NavigationLink(destination: GroupProposalDetailView(proposal: proposal)) {
                        ProposalRow(proposal: proposal)
                    }
                }

                if viewModel.groupProposals.filter({ $0.status == .confirmed }).isEmpty {
                    Text("확정된 제안이 없습니다")
                        .foregroundColor(.gray)
                        .italic()
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("그룹 일정 제안")
        .onAppear {
            viewModel.fetchGroupProposals(for: groupID)
        }
        .refreshable {
            viewModel.fetchGroupProposals(for: groupID)
        }
    }
}

// 제안 행 컴포넌트
struct ProposalRow: View {
    let proposal: GroupScheduleProposal

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(proposal.title)
                .font(.headline)

            Text(proposal.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(1)

            HStack {
                Text("제안자: \(proposal.createdBy)")
                    .font(.caption)
                    .foregroundColor(.gray)

                Spacer()

                Text(formattedDate(proposal.createdAt))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            // 후보 개수 표시
            Text("\(proposal.proposals.count)개의 후보 날짜")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 8)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        GroupProposalListView(groupID: "group1")
    }
}
