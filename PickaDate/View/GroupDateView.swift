//
//  GroupDateView.swift
//  PickaDate
//
//  Created by NoelMacMini on 2/22/25.
//

import SwiftUI

struct GroupDateView: View {
    // MARK: - Properties
    @StateObject private var viewModel = GroupDateViewModel()
    @State private var selectedDate = Date() // 선택된 날짜를 저장
    @State private var currentMonth: Date = Date()  // 현재 표시중인 월
    @State private var isShowingAddGroupSchedulePeriod = false
    let groupName = "맛있는거사조"
    
    // 달력에 표시할 날짜들을 저장하는 배열
    private var days: [Date] {
        getDaysInMonth(for: currentMonth)
    }
    
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack {
                // 캘린더 섹션
                // 헤더 부분
                CalendarHeaderView(
                    currentMonth: currentMonth,
                    groupName: groupName
                )
                
                // 요일 헤더
                WeekdayHeaderView()
                
                // 날짜 그리드
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { date in
                        let schedules = getSchedulesForDate(date)
                        DayCell(
                            date: date,
                            isSelected: isSameDay(date, selectedDate),
                            isCurrentMonth: isSameMonth(date, currentMonth),
                            schedules: schedules
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    }
                }
                // 추가 버튼
                AddScheduleButton(isShowingSheet: $isShowingAddGroupSchedulePeriod, groupName: groupName)
            }
            .navigationTitle("그룹 일정")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.fetchGroupSchedules()
            }
        }
    }
    
    // MARK: - Helper Views
    private struct DayCell: View {
        let date: Date
        let isSelected: Bool
        let isCurrentMonth: Bool
        let schedules: [GroupSchedule]
        
        var body: some View {
            VStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .foregroundColor(isCurrentMonth ? .black : .gray)
                
                if !schedules.isEmpty {
                    VStack {
                        ForEach(schedules) { schedule in
                            Text(schedule.name)
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.blue)
                                .cornerRadius(5)
                        }
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .border(Color.gray)
        }
    }
    
    private struct CalendarHeaderView: View {
        let currentMonth: Date
        let groupName: String
        
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
    
    private struct AddScheduleButton: View {
        @Binding var isShowingSheet: Bool
        let groupName: String
        
        var body: some View {
            VStack {
                Spacer()
                Button(action: { isShowingSheet.toggle() }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .frame(width: 50, height: 50)
                        .padding()
                }
                .frame(width: 80, height: 80)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(40)
                .padding(.bottom, 20)
                .sheet(isPresented: $isShowingSheet) {
                    AddGroupScheduleView(groupName: groupName)
                }
            }
        }
    }
    
    // MARK: - Methods
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
    
    private func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        
        // 해당 월의 첫날과 마지막날 구하기
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        // 첫 주부터 마지막 주까지의 모든 날짜를 배열로 만들기
        var result: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            result.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return result
    }
    
//    func formattedDate(_ date: Date) -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "ko_KR")
//        formatter.dateFormat = "yyyy년 M월"
//        return formatter.string(from: date)
//    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date1) == calendar.component(.month, from: date2) &&
               calendar.component(.year, from: date1) == calendar.component(.year, from: date2)
    }
    
    private func getSchedulesForDate(_ date: Date) -> [GroupSchedule] {
        viewModel.groupSchedule.filter { schedule in
            schedule.schedule.contains { timeSlot in
                Calendar.current.isDate(date, inSameDayAs: timeSlot.startTime) ||
                Calendar.current.isDate(date, inSameDayAs: timeSlot.endTime) ||
                (date >= timeSlot.startTime && date <= timeSlot.endTime)
            }
        }
    }
}


// MARK: - Preview
#Preview {
    GroupDateView()
}
