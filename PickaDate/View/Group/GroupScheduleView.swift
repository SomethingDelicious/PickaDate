//
//  GroupScheduleView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI

struct GroupScheduleView: View {
    // MARK: - Properties
    @EnvironmentObject private var groupViewModel: GroupViewModel // 그룹 정보
    @StateObject private var viewModel = GroupCalendarViewModel() // 그룹 캘린더 정보
    @State private var selectedDate = Date() // 선택된 날짜를 저장
    @State private var currentMonth: Date = Date()  // 현재 표시중인 월
    @State private var isShowingAddGroupSchedulePeriod = false
    @State private var cellHeight: CGFloat = 0 // GeometryReader 사용을 위한 변수
    @State private var isShowingProposalList = false // 일정제안목록 보이기
    
    // 달력에 표시할 날짜들을 저장하는 배열
    private var days: [Date] {
        getDaysInMonth(for: currentMonth)
    }
    
    // 연도와 월 계산
    private var year: Int {
        Calendar.current.component(.year, from: currentMonth)
    }
    private var month: Int {
        Calendar.current.component(.month, from: currentMonth)
    }
    
    
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            if let currentGroup = groupViewModel.currentGroup {
                GeometryReader { geometry in
                    let minimumCellHeight: CGFloat = 60
                    let headerHeight: CGFloat = 170
                    let requiredHeight = minimumCellHeight * 7
                    let cellHeight = geometry.size.height <= (headerHeight + requiredHeight)
                    ? minimumCellHeight
                    : (geometry.size.height - headerHeight) / 7
                    
                    VStack {
                        // 캘린더 헤더 (월 선택 및 그룹 이름 표시)
                        CalendarHeaderView(
                            currentMonth: currentMonth,
                            groupName: currentGroup.groupName,
                            groupId: currentGroup.groupID,
                            onProposalListTap: {
                                // 월이 변경되면 새 월의 일정 상태 계산
                                viewModel.calculateMonthScheduleStatus(
                                    groupID: currentGroup.groupID,
                                    year: year,
                                    month: month
                                )
                                //TODO: 일정 제안 목록 표시 (여기에 구현 필요)
                                isShowingProposalList.toggle()
                            }
                        )
                        
                        // 요일 헤더
                        WeekdayHeaderView()
                        
                        // 날짜 그리드
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                            ForEach(days, id: \.self) { date in
                                let status = viewModel.getScheduleStatusForDate(date)
                                DayCell(
                                    date: date,
                                    isSelected: isSameDay(date, selectedDate),
                                    isCurrentMonth: isSameMonth(date, currentMonth),
                                    scheduleStatus: status
                                )
                                .onTapGesture {
                                    selectedDate = date
                                    // 여기에 날짜 선택 시 수행할 작업 추가
                                }
                            }
                        }
                        .gesture(
                            DragGesture()
                                .onEnded { value in
                                    if value.translation.width < -30 {
                                        changeMonth(by: 1)
                                    } else if value.translation.width > 30 {
                                        changeMonth(by: -1)
                                    }
                                    
                                }
                        )
                    } //VStack1
                    .padding(.bottom, 30) // 하단 탭바와의 간격
                } // GeometryReader1
                .sheet(isPresented: $isShowingProposalList) {
                    // 새 리스트 뷰를 열되 파라미터 전달 없이 환경 객체 사용
                    GroupProposalListView()
                        .environmentObject(groupViewModel)
                        .environmentObject(viewModel)
                    
                }
                .navigationTitle("그룹 일정")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    // 현재 그룹의 일정 정보 가져오기
                    viewModel.fetchGroupSchedules(groupID: currentGroup.groupID)
                    Task {
                        await viewModel.fetchGroupProposals(for: currentGroup.groupID)
                    }
                    // 현재 달의 일정 상태 계산
                    viewModel.calculateMonthScheduleStatus(
                        groupID: currentGroup.groupID,
                        year: year,
                        month: month
                    )
                } // GeometryReader1/onAppear
            } else {
                // 선택된 그룹이 없는 경우
                VStack(spacing: 20) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    
                    Text("선택된 그룹이 없습니다.")
                        .font(.headline)
                    
                    Text("그룹을 선택하거나 생성하세요.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    NavigationLink(destination: GroupListView()) {
                        Text("그룹 선택하기")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
            } // NavigationStack1
        } // Body
    }
    
    // MARK: - Helper Views
        
    private struct DayCell: View {
        let date: Date
        let isSelected: Bool
        let isCurrentMonth: Bool
        let scheduleStatus: (withSchedule: Int, withoutSchedule: Int)
        
        var body: some View {
            VStack {
                // 날짜 숫자
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(size: 14))
                    .foregroundColor(isCurrentMonth ? .black : .gray)
                    .padding(4)
                    .background(isSelected ? Color.blue.opacity(0.3) : Color.clear)
                    .clipShape(Circle())
                
                // 일정 상태 표시
                if isCurrentMonth && (scheduleStatus.withSchedule > 0 || scheduleStatus.withoutSchedule > 0) {
                    VStack(spacing: 2) {
                        if scheduleStatus.withSchedule > 0 {
                            Text("일정: \(scheduleStatus.withSchedule)명")
                                .font(.system(size: 8))
                                .padding(2)
                                .background(getScheduleStatusColor(ratio: Double(scheduleStatus.withSchedule) / Double(scheduleStatus.withSchedule + scheduleStatus.withoutSchedule)))
                                .cornerRadius(4)
                                .foregroundColor(.white)
                        }
                        
//                        Text("총 \(scheduleStatus.withSchedule + scheduleStatus.withoutSchedule)명")
//                            .font(.system(size: 8))
//                            .foregroundColor(.gray)
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
            }
            .frame(height: 70)
            .padding(2)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)
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
    }
    
    
    private struct CalendarHeaderView: View {
        let currentMonth: Date
        let groupName: String
        let groupId: String
        // 버튼 액션을 위한 클로저 속성 추가
        let onProposalListTap: () -> Void
        
        private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 M월"
            return formatter.string(from: date)
        }
        
        var body: some View {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.green)
                VStack(alignment: .leading) {
                    Text(formattedDate(currentMonth))
                        .font(.headline)
                        .bold()
                    Text(groupName)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 일정 제안 목록 버튼 추가
                Button(action: onProposalListTap) {
                    // isShowingProposalList 토글 코드
                    Image(systemName: "list.bullet")
                        .foregroundStyle(.blue)
                }
                
                Button(action: {}) {
                    Image(systemName: "star")
                }
                Button(action: {}) {
                    Image(systemName: "bubble.right")
                }
            }
            .padding()
        }
    }
    
    private struct WeekdayHeaderView: View {
        private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
        
        var body: some View {
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    // MARK: - Methods
    // 캘린더의 첫주를 구하는 함수
    func getFirstWeekday(of year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        
        // 해당 월의 1일 날짜 구하기
        let firstDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        
        // 해당 월의 1일이 있는 주의 일요일 날짜 구하기
        let firstSunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstDate))!
        
        // 1일과 그 주의 일요일 사이의 일수 차이 구하기
        let difference = calendar.dateComponents([.day], from: firstSunday, to: firstDate).day ?? 0
        
        return difference
    }
    
    // 이전 달의 마지막 날짜들을 가져오는 함수
    func getLastDaysOfPreviousMonth(year: Int, month: Int, count: Int) -> [Int] {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        
        // 이전 달의 마지막 날 구하기
        let firstDayOfMonth = calendar.date(from: components)!
        let lastDayOfPrevMonth = calendar.date(byAdding: .day, value: -1, to: firstDayOfMonth)!
        
        let lastDay = calendar.component(.day, from: lastDayOfPrevMonth)
        
        // 필요한 만큼의 이전 달 날짜 배열 만들기
        return (0..<count).map { lastDay - count + $0 + 1 }
    }
    
    // 캘린더에 들어갈 날짜 배열을 만드는 함수
    private func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // 해당 월의 첫날과 마지막날 구하기
        guard let monthInterval = calendar.dateInterval(of: .month, for: date) else {
            return []
        }
        
        let monthStartDate = monthInterval.start
        
        let firstWeekday = calendar.component(.weekday, from: monthStartDate)
        let previousDays = firstWeekday - 1 // 이전 달에서 필요한 날짜 수
        
        // 첫 주 일요일 날짜 구하기
        guard let firstDateOfGrid = calendar.date(byAdding: .day, value: -previousDays, to: monthStartDate) else {
            return []
        }
        
        // 첫 주부터 마지막 주까지의 모든 날짜를 배열로 만들기(42일, 6주에 맞춰서 날짜 생성)
        var result: [Date] = []
        var currentDate = firstDateOfGrid
        
        for _ in 0..<42 { // 6주 x 7일 = 42일
            result.append(currentDate)
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDate
        }
        
        return result
    }
    
    // Day 확인
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    // Month 확인
    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date1) == calendar.component(.month, from: date2) &&
        calendar.component(.year, from: date1) == calendar.component(.year, from: date2)
    }
    // 확인한 날짜에 해당하는 일정들을 가져오는 메서드
    private func getSchedulesForDate(_ date: Date) -> [PDGroupSchedule] {
        viewModel.groupSchedules.filter { schedule in
            let timeSlot = schedule.schedule
            return Calendar.current.isDate(date, inSameDayAs: timeSlot.startTime) ||
                   Calendar.current.isDate(date, inSameDayAs: timeSlot.endTime) ||
                   (date >= timeSlot.startTime && date <= timeSlot.endTime)
        }
    }
    
    // 스와이프 기능을 위한 changeMonth 메서드 추가
    private func changeMonth(by value: Int) {
        withAnimation {
            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
                currentMonth = newDate
                
                // 월이 변경되면 새 월의 일정 상태 계산
                if let currentGroup = groupViewModel.currentGroup {
                    viewModel.calculateMonthScheduleStatus(
                        groupID: currentGroup.groupID,
                        year: Calendar.current.component(.year, from: newDate),
                        month: Calendar.current.component(.month, from: newDate)
                    )
                }
            }
        }
    }
}


//// MARK: - Preview
//#Preview {
//    GroupScheduleView()
//}
