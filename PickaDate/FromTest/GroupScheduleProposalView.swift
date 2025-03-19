//
//  GroupScheduleProposalView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI
 import FirebaseFirestore
 
 struct GroupScheduleProposalView: View {
     @Environment(\.presentationMode) var presentationMode
     @StateObject private var proposalViewModel = GroupProposalViewModel()
     
     let userID: String  // 현재 사용자 ID
     let groupID: String // 그룹 ID를 받아옵니다
     
     @State private var proposalTitle: String = "" // 제안 제목
     @State private var proposalDescription: String = "" // 제안 설명
     @State private var proposals: [ScheduleProposal] = [ScheduleProposal()] // 일정 후보 배열
     
     var body: some View {
         NavigationView {
             Form {
                 // 제안 기본 정보 섹션
                 Section(header: Text("제안 정보").foregroundColor(.black)) {
                     TextField("제안 제목", text: $proposalTitle)
                         .foregroundColor(.black)
                     
                     TextField("설명", text: $proposalDescription)
                         .foregroundColor(.black)
                 }
                 
                 // 일정 후보 섹션
                 Section(header: HStack {
                     Text("일정 후보").foregroundColor(.black)
                     Spacer()
                     Button(action: {
                         withAnimation {
                             addNewProposal()
                         }
                     }) {
                         Text("+ 후보 추가")
                             .foregroundColor(.blue)
                     }
                 }) {
                     ForEach(proposals.indices, id: \.self) { index in
                         ProposalItemView(
                             proposal: $proposals[index],
                             index: index + 1,
                             onDelete: {
                                 withAnimation {
                                     deleteProposal(at: index)
                                 }
                             }
                         )
                     }
                 }
             }
             .navigationTitle("그룹 일정 제안")
             .toolbar {
                 ToolbarItem(placement: .navigationBarLeading) {
                     Button("취소") {
                         presentationMode.wrappedValue.dismiss()
                     }
                     .foregroundColor(.black)
                 }
                 
                 ToolbarItem(placement: .navigationBarTrailing) {
                     Button("저장") {
                         saveProposal()
                     }
                     .foregroundColor(.black)
                     .disabled(proposalTitle.isEmpty || proposals.isEmpty || !isValidProposals())
                 }
             }
         }
     }
     
     // 새 후보 추가
     private func addNewProposal() {
         if proposals.count < 10 { // 일단 10개 제한 설정
             proposals.append(ScheduleProposal())
         }
     }
     
     // 후보 삭제
     private func deleteProposal(at index: Int) {
         if proposals.count > 1 { // 최소 하나의 후보는 유지
             proposals.remove(at: index)
         }
     }
     
     // 제안이 유효한지 확인
     private func isValidProposals() -> Bool {
         return proposals.allSatisfy { !$0.title.isEmpty && !$0.selectedDates.isEmpty }
     }
     
     // 제안 저장
     private func saveProposal() {
         guard !proposalTitle.isEmpty && !proposals.isEmpty && isValidProposals() else {
             return
         }
 
         proposalViewModel.addGroupProposal(
             groupID: groupID,
             title: proposalTitle,
             description: proposalDescription,
             createdBy: userID,
             proposals: proposals
         )
 
         presentationMode.wrappedValue.dismiss()
     }
 }
 
 // 각 일정 후보 항목 뷰
 struct ProposalItemView: View {
     @Binding var proposal: ScheduleProposal
     let index: Int
     let onDelete: () -> Void
     
     var body: some View {
         VStack(alignment: .leading) {
             HStack {
                 Text("후보 \(index)")
                     .font(.headline)
                 Spacer()
                 Button(action: onDelete) {
                     Image(systemName: "trash")
                         .foregroundColor(.red)
                 }
             }
             
             TextField("후보 제목", text: $proposal.title)
                 .padding(.vertical, 4)
             
             // 선택된 날짜 표시
             if proposal.selectedDates.isEmpty {
                 Text("선택된 날짜가 없습니다")
                     .foregroundColor(.gray)
                     .padding(.vertical, 8)
             } else {
                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack {
                         ForEach(proposal.selectedDates, id: \.self) { date in
                             Text(formattedDate(date))
                                 .padding(6)
                                 .background(Color.blue.opacity(0.2))
                                 .cornerRadius(8)
                         }
                     }
                 }
                 .padding(.vertical, 8)
             }
             
             Button(action: {
                 proposal.showingDatePicker.toggle()
             }) {
                 Text("날짜 선택")
                     .foregroundColor(.blue)
             }
             .sheet(isPresented: $proposal.showingDatePicker) {
                 DateSelectionView(selectedDates: $proposal.selectedDates)
             }
         }
         .padding(.vertical, 8)
     }
     
     private func formattedDate(_ date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = "MM/dd (E)"
         formatter.locale = Locale(identifier: "ko_KR")
         return formatter.string(from: date)
     }
 }
 
 // 일정 후보 데이터 모델
 struct ScheduleProposal: Identifiable {
     var id = UUID()
     var title: String = ""
     var selectedDates: [Date] = []
     var showingDatePicker: Bool = false
 }
 
 #Preview {
     GroupScheduleProposalView(userID: "jiyong7578", groupID: "group1")
 }
