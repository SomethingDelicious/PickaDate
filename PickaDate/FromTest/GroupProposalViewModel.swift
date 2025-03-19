////
////  GroupProposalViewModel.swift
////  PickaDate
////
////  Created by NoelMacMini on 3/19/25.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//class GroupProposalViewModel: ObservableObject {
//    private let fsDB = Firestore.firestore()
//    @Published var groupProposals: [GroupScheduleProposal] = []
//
//    // 그룹 제안 목록 가져오기
//    func fetchGroupProposals(for groupID: String) {
//        fsDB.collection("groupProposals")
//            .whereField("groupID", isEqualTo: groupID)
//            .getDocuments { snapshot, error in
//                if let error = error {
//                    print("[E]그룹 제안 가져오기 실패: \(error.localizedDescription)")
//                    return
//                }
//
//                DispatchQueue.main.async {
//                    self.groupProposals = snapshot?.documents.compactMap { doc in
//                        try? doc.data(as: GroupScheduleProposal.self)
//                    } ?? []
//                }
//            }
//    }
//
//    // 그룹 제안 추가하기
//    func addGroupProposal(groupID: String, title: String, description: String, createdBy: String, proposals: [ScheduleProposal]) {
//        let proposalID = UUID().uuidString
//
//        // 일정 후보 변환
//        let proposalsData: [Proposal] = proposals.map { proposal in
//            Proposal(
//                title: proposal.title,
//                dates: proposal.selectedDates,
//                votes: []
//            )
//        }
//
//        let proposalData: [String: Any] = [
//            "proposalID": proposalID,
//            "groupID": groupID,
//            "title": title,
//            "description": description,
//            "createdAt": FieldValue.serverTimestamp(),
//            "createdBy": createdBy,
//            "proposals": proposalsData.map { proposal in
//                return [
//                    "id": proposal.id,
//                    "title": proposal.title,
//                    "dates": proposal.dates,
//                    "votes": proposal.votes
//                ]
//            },
//            "status": ProposalStatus.pending.rawValue
//        ]
//
//        fsDB.collection("groupProposals").document(proposalID).setData(proposalData) { error in
//            if let error = error {
//                print("[E]그룹 제안 추가 실패: \(error.localizedDescription)")
//            } else {
//                print("[L]그룹 제안 추가 성공")
//                self.fetchGroupProposals(for: groupID)
//            }
//        }
//    }
//
//    // 그룹 제안 투표하기
//    func voteForProposal(proposalID: String, optionID: String, userID: String) {
//        let proposalRef = fsDB.collection("groupProposals").document(proposalID)
//
//        // 트랜잭션으로 안전하게 처리
//        fsDB.runTransaction({ (transaction, errorPointer) -> Any? in
//            let proposalDocument: DocumentSnapshot
//            do {
//                try proposalDocument = transaction.getDocument(proposalRef)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            guard let proposal = try? proposalDocument.data(as: GroupScheduleProposal.self) else {
//                return nil
//            }
//
//            // 해당 옵션 찾기
//            guard let optionIndex = proposal.proposals.firstIndex(where: { $0.id == optionID }) else {
//                return nil
//            }
//
//            var updatedProposals = proposal.proposals
//
//            // 이미 투표했으면 취소, 아니면 추가
//            if updatedProposals[optionIndex].votes.contains(userID) {
//                updatedProposals[optionIndex].votes.removeAll(where: { $0 == userID })
//            } else {
//                updatedProposals[optionIndex].votes.append(userID)
//            }
//
//            transaction.updateData([
//                "proposals": updatedProposals.map { proposal in
//                    return [
//                        "id": proposal.id,
//                        "title": proposal.title,
//                        "dates": proposal.dates,
//                        "votes": proposal.votes
//                    ]
//                }
//            ], forDocument: proposalRef)
//
//            return nil
//        }) { (_, error) in
//            if let error = error {
//                print("[E]투표 처리 실패: \(error.localizedDescription)")
//            } else {
//                print("[L]투표 처리 성공")
//            }
//        }
//    }
//
//    // 그룹 제안 상태 변경하기
//    func updateProposalStatus(proposalID: String, status: ProposalStatus) {
//        fsDB.collection("groupProposals").document(proposalID).updateData([
//            "status": status.rawValue
//        ]) { error in
//            if let error = error {
//                print("[E]제안 상태 변경 실패: \(error.localizedDescription)")
//            } else {
//                print("[L]제안 상태 변경 성공")
//            }
//        }
//    }
//}
