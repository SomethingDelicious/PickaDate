//
//  ProposalDetailView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/20/25.
//

import SwiftUI

struct ProposalDetailView: View {
    // MARK: - Properties
    @EnvironmentObject private var calendarViewModel: GroupCalendarViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var groupViewModel: GroupViewModel
    @Environment(\.dismiss) private var dismiss
    
    // 제안 정보
    let proposal: GroupScheduleProposal
    
    // 사용자 선택 상태
    @State private var userSelectedOptions: [Int: Bool] = [:]
    @State private var selectedOptionForConfirmation: Int? = nil
    
    // 현재 사용자가 그룹의 리더인지 확인
    private var isGroupLeader: Bool {
        if let currentGroup = groupViewModel.currentGroup {
            return userViewModel.currentUser?.userID == currentGroup.leaderID
        }
        return false
    }
    
    // 현재 사용자가 확인을 완료했는지 여부
    private var hasUserChecked: Bool {
        guard let userID = userViewModel.currentUser?.userID else { return false }
        return proposal.checkedMembers.contains(userID)
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 제목 및 정보 섹션
                headerSection
                
                // 내용 섹션
                contentSection
                
                // 일정 옵션 섹션
                scheduleOptionsSection
                
                // 확인 현황 섹션
                checkStatusSection
                
                // 버튼 섹션
                if proposal.status == .pending {
                    buttonSection
                } else {
                    // 확정되었거나 최소된 경우 상태 메시지
                    statusMessageSection
                }
            }
            .padding()
        }
        .navigationTitle("일정 제안 상세")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            userViewModel.fetchUserSchedules()
            loadUserAvailability()
            
            // 제안된 일정 날짜들이 속한 달의 일정 상태 계산 요청
            Task {
                // 모든 제안 날짜가 속한 년/월 확인
                let calendar = Calendar.current
                var monthsToCalculate = Set<String>() // "YYYY-MM" 형태의 문자열 저장
                
                for timeSlot in proposal.schedules {
                    let date = timeSlot.startTime
                    let year = calendar.component(.year, from: date)
                    let month = calendar.component(.month, from: date)
                    let yearMonthString = "\(year)-\(month)"
                    monthsToCalculate.insert(yearMonthString)
                }
                
                // 각 월에 대해 일정 상태 계산 요청
                if let groupID = groupViewModel.currentGroup?.groupID {
                    for yearMonthString in monthsToCalculate {
                        let components = yearMonthString.split(separator: "-")
                        if components.count == 2,
                           let year = Int(components[0]),
                           let month = Int(components[1]) {
                            // 이미 계산된 월인지 확인 (선택적)
                            calendarViewModel.calculateMonthScheduleStatus(groupID: groupID, year: year, month: month)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Section Views
    // 제목 및 정보 섹션
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(proposal.title)
                .font(.title2)
                .fontWeight(.bold)
            Text("그룹: \(proposal.groupName)")
                .font(.subheadline)
                .foregroundStyle(.gray)
            
            Text("제안자: \(proposal.creatorName)")
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
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    // 내용 섹션
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("내용")
                .font(.headline)
            
            Text(proposal.content)
                .padding()
                .background(Color.gray.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding()
    }
    
    // 일정 옵션 섹션
    private var scheduleOptionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("제안 일정")
                .font(.headline)
            
            ForEach(Array(proposal.schedules.enumerated()), id: \.offset) { index, timeSlot in
                // 개인 일정 충돌 여부 확인
                let hasConflict = checkScheduleConflict(with: timeSlot)
                
                // 시작 날짜의 일정 상태 조회
                let startDate = timeSlot.startTime
                let scheduleStatus = calendarViewModel.getScheduleStatusForDate(startDate)
                
                ScheduleOptionView(
                    index: index,
                    timeSlot: timeSlot,
                    isAvailable: userSelectedOptions[index, default: !hasConflict],
                    isConfirmed: proposal.confirmedOptionIndex == index,
                    hasConflict: hasConflict,
                    color: colorMap[proposal.groupColor, default: .blue],
                    isEditable: proposal.status == .pending,
                    withSchedule: scheduleStatus.withSchedule,
                    withoutSchedule: scheduleStatus.withoutSchedule,
                    isLeader: isGroupLeader,
                    isSelectedForConfirmation: selectedOptionForConfirmation == index,
                    onToggleAvailability: {
                        userSelectedOptions[index] = !(userSelectedOptions[index] ?? !hasConflict)
                    },
                    onSelectForConfirmation: {
                        // 이미 선택된 옵션이면 선택 해제, 아니면 선택
                        if selectedOptionForConfirmation == index {
                            selectedOptionForConfirmation = nil
                        } else {
                            selectedOptionForConfirmation = index
                        }
                    }
                )
            }
        }
        .padding()
    }
    
    // 확인 현황 섹션
    private var checkStatusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("일정 확인 현황")
                .font(.headline)
            Text("확인 완료: \(proposal.checkedMembers.count)명")
                .foregroundStyle(.blue)
            Text("미확인: \(proposal.unCheckedMembers.count)명")
                .foregroundStyle(.red)
        }
        .padding()
    }
    
    // 버튼 섹션
    private var buttonSection: some View {
        VStack(spacing: 16) {
            // 일반 사용자용 버튼
            if !hasUserChecked {
                Button(action: confirmCheck) {
                    Text("확인 완료")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            } else {
                Button(action: confirmCheck) {
                    Text("수정 완료")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            
            // 리더용 추가 버튼
            if isGroupLeader && proposal.status == .pending {
                Button(action: confirmSchedule) {
                    Text("일정 확정하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .disabled(selectedOptionForConfirmation == nil)  // 옵션이 선택되지 않으면 비활성화
                
                Button(action: cancelProposal) {
                    Text("제안 취소하기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        } // VStack1
        .padding()
    }
    
    // 상태 메세지 섹션 (확정됨 또는 취소됨 상태)
    private var statusMessageSection: some View {
        VStack(spacing: 16) {
            switch proposal.status {
            case .confirmed:
                if let index = proposal.confirmedOptionIndex, index < proposal.schedules.count {
                    let confirmedOption = proposal.schedules[index]
                    VStack(alignment: .leading, spacing: 8) {
                        Text("확정된 일정")
                            .font(.headline)
                        
                        Text("날짜: \(formatDate(confirmedOption.startTime))")
                        
                        if confirmedOption.isAllDay {
                            Text("종일")
                        } else {
                            Text("시간: \(formatTime(confirmedOption.startTime)) ~ \(formatTime(confirmedOption.endTime))")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            case .canceled:
                Text("이 일정 제안은 취소되었습니다")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            default:
                EmptyView()
            }
        }
        .padding()
    }
    
    
    // MARK: - Helper Methods
    
    // 사용자의 일정 가능 여부 로드
    private func loadUserAvailability() {
        guard let userID = userViewModel.currentUser?.userID else { return }
        
        // 디버깅을 위한 로그 추가
        print("Loading availability for user: \(userViewModel.currentUser?.userName ?? "Unknown User")")
        print("Current user schedules: \(userViewModel.userSchedules.count)")
        
        // 기존에 저장된 가능/불가능 상태 로드
        if let availability = proposal.memberAvailability[userID] {
            print("Found saved availability: \(availability)")
            for (indexStr, isAvailable) in availability {
                if let index = Int(indexStr) {
                    userSelectedOptions[index] = isAvailable
                    print("Option \(index): \(isAvailable ? "Available" : "Unavailable")")
                }
            }
        } else {
            print("No saved availability, checking conflicts")
            // 새로운 사용자의 경우 개인 일정과 겹치는지 확인하며 초기 상태 설정
            for (index, option) in proposal.schedules.enumerated() {
                let hasConflict = checkScheduleConflict(with: option)
                userSelectedOptions[index] = !hasConflict // 충돌이 없으면 가능, 있으면 불가능
                print("Option \(index): \(hasConflict ? "Conflict detected" : "No conflict") -> \(!hasConflict ? "Available" : "Unavailable")")
            }
        }
    }
    // 옵션의 가능/불가능 상태 토글
    private func toggleOptionAvailability(index: Int) {
        userSelectedOptions[index] = !(userSelectedOptions[index] ?? true)
    }
    // 개인 일정과 충돌 여부 확인
    private func checkScheduleConflict(with option: TimeSlotGroup) -> Bool {
        let calendar = Calendar.current
        let optionStartDay = calendar.startOfDay(for: option.startTime)
        let optionEndDay = calendar.startOfDay(for: option.endTime)
        
        print("Checking conflicts for option:")
        print("  Option Start: \(option.startTime) (\(formatDateTime(option.startTime)))")
        print("  Option End: \(option.endTime) (\(formatDateTime(option.endTime)))")
        print("  Option Start Day: \(optionStartDay) (\(formatDate(optionStartDay)))")
        print("  Option End Day: \(optionEndDay) (\(formatDate(optionEndDay)))")
        print("  Is All Day: \(option.isAllDay)")
        
        // 사용자의 개인 일정과 옵션 시간이 겹치는지 확인
        // for schedule in userViewModel.userSchedules {
        for (scheduleIndex, schedule) in userViewModel.userSchedules.enumerated() {
            // for timeSlot in schedule.schedules {
            for (slotIndex, timeSlot) in schedule.schedules.enumerated() {
                // 날짜 범위가 겹치는지 먼저 확인 (최적화)
                let slotStartDay = calendar.startOfDay(for: timeSlot.startTime)
                let slotEndDay = calendar.startOfDay(for: timeSlot.endTime)
                
                print("Comparing with user schedule #\(scheduleIndex), slot #\(slotIndex):")
                print("Slot Start: \(timeSlot.startTime) (\(formatDateTime(timeSlot.startTime)))")
                print("Slot End: \(timeSlot.endTime) (\(formatDateTime(timeSlot.endTime)))")
                print("Slot Start Day: \(slotStartDay) (\(formatDate(slotStartDay)))")
                print("Slot End Day: \(slotEndDay) (\(formatDate(slotEndDay)))")
                print("Is All Day: \(timeSlot.isAllDay)")
                
                // 날짜 범위가 겹치지 않으면 다음 일정 확인
                if slotEndDay < optionStartDay || slotStartDay > optionEndDay {
                    print("날짜 범위가 겹치지 않음 - continuing to next slot")
                    continue
                }
                print("날짜 겹침")
                
                // 시간 범위가 겹치는지 확인
                if option.isAllDay || timeSlot.isAllDay {
                    print("일정 충돌 감지: 최소 하나의 종일 일정: \(option.isAllDay), \(timeSlot.isAllDay)")
                    return true // 하나라도 종일 일정이면 충돌
                } else if max(option.startTime, timeSlot.startTime) < min(option.endTime, timeSlot.endTime) {
                    print("시간 범위 충돌 감지: \(option.startTime) ~ \(option.endTime), \(timeSlot.startTime) ~ \(timeSlot.endTime)")
                    return true // 시간 범위가 겹치면 충돌
                } else {
                    print("시간 충돌 감지 안됨")
                }
            }
        }
        print("충돌 찾지 못함")
        return false // 충돌 없음
    }
    
    // 확인 완료
    private func confirmCheck() {
        guard let userID = userViewModel.currentUser?.userID,
              let userName = userViewModel.currentUser?.userName else { return }
        
        // 사용자의 가능/불가능 상태를 ViewModel에 저장
        var availabilityMap: [Int: Bool] = [:]
        for (index, isAvailable) in userSelectedOptions {
            availabilityMap[index] = isAvailable
        }
        
        do {
            
            // ViewModel을 통해 Firestore에 업데이트 요청
            calendarViewModel.updateUserAvailability(
                proposalID: proposal.proposalID,
                userID: userID,
                userName: userName,
                availability: availabilityMap
            )
            print("사용자 \(userID)가 일정 확인 완료")
            // 성공 시 화면 닫기
            dismiss()
        } catch {
            // 오류 처리
            print("[E] 일정 확인 업데이트 실패: \(error.localizedDescription)")
        }
    }
    
    // 일정 확정 (그룹 리더만 사용)
    private func confirmSchedule() {
        // 선택된 옵션이 없으면 확정 불가
        guard isGroupLeader, let selectedOption = selectedOptionForConfirmation else {
            // 선택된 옵션이 없다는 알림 표시
            print("선택된 옵션이 없습니다")
            return
        }
        
        do {
            // ViewModel을 통해 일정 확정
            calendarViewModel.confirmProposal(
                proposalID: proposal.proposalID,
                selectedOptionIndex: selectedOption
            )
            print("일정 확정: 옵션 \(selectedOption + 1)")
            dismiss()
        } catch {
            print("[E] 일정 확정 실패: \(error.localizedDescription)")
        }
    }
    
    // 제안 취소 (그룹 리더만 사용)
    private func cancelProposal() {
        guard isGroupLeader else { return }
        
        do {
            // ViewModel을 통해 제안 취소
            calendarViewModel.cancelProposal(proposalID: proposal.proposalID)
            print("제안 취소")
            dismiss()
        } catch {
            print("[E] 제안 취소 실패: \(error.localizedDescription)")
        }
    }
    
    // 날짜 및 시간 포맷팅
    private func formatDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 HH:mm"
        return formatter.string(from: date)
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

// MARK: - 보조 뷰

// 일정 옵션 뷰
struct ScheduleOptionView: View {
    let index: Int
    let timeSlot: TimeSlotGroup
    let isAvailable: Bool
    let isConfirmed: Bool
    let hasConflict: Bool
    let color: Color
    let isEditable: Bool
    let withSchedule: Int    // 일정 있는 멤버 수
    let withoutSchedule: Int // 일정 없는 멤버 수
    let isLeader: Bool       // 리더 여부 추가
    let isSelectedForConfirmation: Bool  // 확정 선택 여부 추가
    let onToggleAvailability: () -> Void
    let onSelectForConfirmation: () -> Void  // 확정 선택 콜백 추가
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 리더용 체크박스
                if isLeader && !isConfirmed {
                    Button(action: onSelectForConfirmation) {
                        Image(systemName: isSelectedForConfirmation ? "checkmark.square.fill" : "square")
                            .foregroundStyle(isSelectedForConfirmation ? .green : .gray)
                    }
                    .padding(.trailing, 4)
                }
                
                Text("옵션 \(index + 1)")
                    .font(.headline)
                
                if isConfirmed {
                    Text("(확정)")
                        .foregroundStyle(.green)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                // 일정 상태 표시
                let totalMembers = withSchedule + withoutSchedule
                if totalMembers > 0 {
                    Text("당일 일정: \(withSchedule)명")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(getScheduleStatusColor(ratio: Double(withSchedule) / Double(totalMembers)))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
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
                
                // 가능/불가능 토글 버튼
                if isEditable {
                    HStack(spacing: 8) {
                        Button(action: onToggleAvailability) {
                            VStack {
                                Image(systemName: isAvailable ? "checkmark.circle.fill" : "checkmark.circle")
                                Text("가능")
                                    .font(.caption)
                            }
                            .foregroundStyle(isAvailable ? .blue : .gray)
                        }
                        
                        Button(action: onToggleAvailability) {
                            VStack {
                                Image(systemName: !isAvailable ? "xmark.circle.fill" : "xmark.circle")
                                Text("불가능")
                                    .font(.caption)
                            }
                            .foregroundStyle(!isAvailable ? .red : .gray)
                        }
                    }
                } else {
                    // 편집 불가능한 상태에서는 상태만 표시
                    Text(isAvailable ? "참여 가능" : "참여 불가능")
                        .foregroundStyle(isAvailable ? .blue : .red)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isConfirmed ? Color.green : (isAvailable ? color.opacity(0.5) : Color.gray.opacity(0.5)), lineWidth: 2)
        )
        .padding(.vertical, 4)
    }
    
    // 일정 상태에 따른 색상 계산
    private func getScheduleStatusColor(ratio: Double) -> Color {
        switch ratio {
        case 0...0.33:
            return .green  // 적은 인원이 일정 있음 (좋음)
        case 0.34...0.66:
            return .orange // 절반 정도 일정 있음 (주의)
        default:
            return .red    // 대부분 일정 있음 (나쁨)
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

