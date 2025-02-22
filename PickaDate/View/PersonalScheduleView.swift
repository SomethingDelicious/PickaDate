//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

//KTG(250222/09:56) : 테스트용 내용입니다. 수정 가능.

import SwiftUI
import FirebaseFirestore

struct PersonalScheduleView: View {
    @StateObject private var viewModel = FirestoreViewModel()
    @State private var isShowingAddSchedule = false
    @State private var isShowingDetailView = false
    @State private var selectedDate: Int? = nil
    @State private var currentDate = Date()
    
    let user = "홍길동"
    
    private var year: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    
    private var month: Int {
        Calendar.current.component(.month, from: currentDate)
    }
    
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    //Color.black.ignoresSafeArea()
                    VStack {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.green)
                            VStack(alignment: .leading) {
                                Text(formattedDate(currentDate))
                                    .font(.headline)
                                    .bold()
                                Text("\(user)")
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
                        
                        GeometryReader { geometry in
                            VStack {
                                // 요일 헤더
                                let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
                                HStack {
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                        ForEach(weekDays, id: \.self) { day in
                                            Text(day)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                                .frame(maxWidth: .infinity)
                                        }
                                    }
                                    
                                }
                                
                                // 날짜 표시
                                let firstWeekday = getFirstWeekday(of: year, month: month)
                                let daysInMonth = getDaysInMonth(year: year, month: month)
                                let totalCells = firstWeekday + daysInMonth
                                let numRows = Int(ceil(Double(totalCells) / 7.0))
                                let cellHeight = 500 / CGFloat(numRows)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                                    // 빈 공간 추가 (첫 요일까지)
                                    ForEach(0..<firstWeekday, id: \.self) { _ in
                                        VStack {
                                            Text("sdf")
                                                
                                            
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: cellHeight)
                                        .border(Color.gray)
                                        
                                    }
                                    
                                    // 날짜 채우기
                                    ForEach(7...(daysInMonth + firstWeekday), id: \.self) { day in
                                        
                                        VStack {
                                            
                                            Text("\(day - firstWeekday)")
                                                .foregroundColor(.white)
                                            
                                            
                                            let schedules = viewModel.personalSchedule.filter { schedule in
                                                schedule.schedule.contains { timeSlot in
                                                    let startDate = convertToDate(timeSlot.startTime)
                                                    let endDate = convertToDate(timeSlot.endTime)
                                                    return isDateInRange(date: day, startDate: startDate, endDate: endDate, year: year, month: month)
                                                }
                                            }
                                            
                                            if !schedules.isEmpty {
                                                VStack {
                                                    ForEach(schedules, id: \.id) { schedule in
                                                        Text(schedule.name)
                                                            .font(.caption)
                                                            .frame(maxWidth: .infinity)
                                                            .foregroundColor(.white)
                                                            .padding(4)
                                                            .background(schedule.color)
                                                            .cornerRadius(5)
                                                    }
                                                }
                                                
                                            }
                                            Spacer()
                                            
                                        }
                                        .frame(maxWidth: .infinity)
                                        .frame(height: cellHeight)
                                        .background(selectedDate == day ? Color.gray.opacity(0.3) : Color.clear)
                                        .border(Color.gray)
                                        .onTapGesture {
                                            if selectedDate == day {
                                                isShowingDetailView = true
                                            } else {
                                                selectedDate = Optional(day)
                                            }
                                        }

                                        
                                    }
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            if value.translation.width < -50 {
                                                changeMonth(by: 1)
                                            } else if value.translation.width > 50 {
                                                changeMonth(by: -1)
                                            }
                                        }
                                )
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.white)
                            .background(Color.black.ignoresSafeArea())
                        }
                        .onAppear {
                            viewModel.fetchPersonalSchedules()
                        }
                        .sheet(isPresented: $isShowingDetailView) {
                            if let safeDate = selectedDate {
                                let selectedSchedules = viewModel.personalSchedule.filter { schedule in
                                    schedule.schedule.contains { timeSlot in
                                        let startDate = convertToDate(timeSlot.startTime)
                                        let endDate = convertToDate(timeSlot.endTime)
                                        return isDateInRange(date: safeDate, startDate: startDate, endDate: endDate, year: year, month: month)
                                    }
                                }
                                PersonalDateScheduleView(selectedDate: safeDate, year: year, month: month, schedules: selectedSchedules, user: user)
                            } else {
                                Text("날짜를 선택하세요.")
                            }
                        }


                        VStack {
                            Spacer()
                            Button(action: {
                                isShowingAddSchedule.toggle()
                            }) {
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
                            .sheet(isPresented: $isShowingAddSchedule) {
                                AddPersonalScheduleView(user: user)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.white)
                    .background(Color.black.ignoresSafeArea())
                    
                }
                Spacer()
            }
        }
    }
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
    private func changeMonth(by value: Int) {
        withAnimation {
            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentDate) {
                currentDate = newDate
            }
        }
    }
    func getFirstWeekday(of year: Int, month: Int) -> Int {
        let calendar = Calendar.current
        let components = DateComponents(year: year, month: month, day: 1)
        
        if let firstDay = calendar.date(from: components) {
            let weekday = calendar.component(.weekday, from: firstDay)
            let test = weekday - 1
            print("2025년 2월의 첫 번째 요일 (0: 일요일, 1: 월요일, ..., 6: 토요일): \(test)")
            return test
            
        }
        return 0
    }
    func getDaysInMonth(year: Int, month: Int) -> Int {
        let components = DateComponents(year: year, month: month)
        if let range = Calendar.current.range(of: .day, in: .month, for: Calendar.current.date(from: components)!) {
            return range.count
        }
        return 30
    }
    func isDateInRange(date: Int, startDate: Date, endDate: Date, year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
        
        return (startComponents.year == year && startComponents.month == month && startComponents.day! <= date) &&
        (endComponents.year == year && endComponents.month == month && endComponents.day! >= date)
    }
    func convertToDate(_ value: Any?) -> Date {
        if let timestamp = value as? Timestamp {
            return timestamp.dateValue()
        } else if let date = value as? Date {
            return date
        }
        return Date()
    }
}




