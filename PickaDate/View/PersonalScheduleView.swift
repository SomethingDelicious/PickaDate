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
    
    let user = "홍길동"
    @State private var currentDate = Date()
    
    private var year: Int {
        Calendar.current.component(.year, from: currentDate)
    }
    
    private var month: Int {
        Calendar.current.component(.month, from: currentDate)
    }
    
    private var selectedDate: Int {
        Calendar.current.component(.day, from: currentDate)
    }
    private var today: Date {
        currentDate
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
                                Text(formattedDate(today))
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
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                            // 빈 공간 추가 (첫 요일까지)
                            ForEach(0..<firstWeekday, id: \.self) { _ in
                                VStack {
                                    Text("syd")
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 100)

                                    Spacer()
                                }
                                .border(Color.gray)
                                
                            }
                            
                            // 날짜 채우기
                            ForEach(1...daysInMonth, id: \.self) { day in
                                VStack {
                                    Text("\(day)")
                                        .foregroundColor(.white)
                                    
                                        
                                    let schedules = viewModel.personalSchedule.filter { schedule in
                                        schedule.schedule.contains { timeSlot in
                                            isDateInRange(date: day, startDate: timeSlot.startTime, endDate: timeSlot.endTime, year: year, month: month)
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
                                .frame(height: 100)
                                .border(Color.gray)
                                
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        Spacer()
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
            .onAppear {
                viewModel.fetchPersonalSchedules()
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
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
    func isDateInRange(date: Int, startDate: Date, endDate: Date, year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
        
        return (startComponents.year == year && startComponents.month == month && startComponents.day! <= date) &&
        (endComponents.year == year && endComponents.month == month && endComponents.day! >= date)
    }
    
}




