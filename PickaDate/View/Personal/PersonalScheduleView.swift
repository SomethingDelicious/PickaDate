////
////  PickaDate
////
////  Created by 김태건 on 2/20/25.
////
//
//import SwiftUI
//import FirebaseFirestore
//
//
//struct PersonalScheduleView: View {
//    @StateObject private var viewModel = FirestoreViewModel()
//    @State private var isShowingAddSchedule = false
//    @State private var isShowingDetailView = false
//    @State private var selectedDate = Date() //일
//    @State private var currentMonth: Date = Date() //월
//    
//    //더미데이터
//    let user = User.init(userID: "1234", userPW: "password", registeredAt: Date(), joinGroup: ["group1", "group2"])
//    
//    private var year: Int {
//        Calendar.current.component(.year, from: selectedDate)
//    }
//    
//    private var month: Int {
//        Calendar.current.component(.month, from: selectedDate)
//    }
//    
//    private var days: [Date] {
//        getDaysInMonth(for: currentMonth)
//    }
//    @State private var selectedYear = Calendar.current.component(.year, from: Date())
//    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
//    
//    var body: some View {
//        NavigationView {
//            VStack {
//                CalendarHeaderView(
//                    currentMonth: $currentMonth,
//                    selectedYear: $selectedYear,
//                    selectedMonth: $selectedMonth,
//                    user: user
//                )
//                WeekdayHeaderView()
//                let firstWeekday = Calendar.current.component(.weekday, from: days.first ?? Date()) - 1
//                let totalCells = firstWeekday + days.count
//                let numRows = Int(ceil(Double(totalCells) / 7.0))
//                let cellHeight = 500 / CGFloat(numRows)
//                
//                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
//                    ForEach(days, id: \.self) { date in
//                        let schedules = getSchedulesForDate(date)
//                        DayCell(
//                            date: date,
//                            isSelected: isSameDay(date, selectedDate),
//                            isCurrentMonth: isSameMonth(date, currentMonth),
//                            schedules: schedules,
//                            cellHeight: cellHeight
//                        )
//                        .background(selectedDate == date ? Color.gray.opacity(0.3) : Color.clear)
//                        .onTapGesture {
//                            if selectedDate == date {
//                                isShowingDetailView = true
//                            } else {
//                                selectedDate = date
//                            }
//                        }
//                    }
//                }
//                .gesture(
//                    DragGesture()
//                        .onEnded { value in
//                            if value.translation.width < -30 {
//                                changeMonth(by: 1)
//                            } else if value.translation.width > 30 {
//                                changeMonth(by: -1)
//                            }
//                            
//                        }
//                    
//                )
//                AddScheduleButton(isShowingSheet: $isShowingAddSchedule, selectedDate: $selectedDate, user: user)
//            }
//            .sheet(isPresented: $isShowingDetailView, onDismiss: {
//                viewModel.fetchPersonalSchedules()
//            }) {
//                let selectedSchedules = viewModel.personalSchedule.filter { schedule in
//                    schedule.schedule.contains { timeSlot in
//                        let startDate = convertToDate(timeSlot.startTime)
//                        let endDate = convertToDate(timeSlot.endTime)
//                        return isDateInRange(date: selectedDate, startDate: startDate, endDate: endDate, year: year, month: month)
//                    }
//                }
//                PersonalDateScheduleView(selectedDate: selectedDate, schedules: selectedSchedules, user: user)
//            }
//            .onAppear {
//                viewModel.fetchPersonalSchedules()
//            }
//            
//        }
//        
//        
//    }
//    
//    private struct DayCell: View {
//        let date: Date
//        let isSelected: Bool
//        let isCurrentMonth: Bool
//        let schedules: [PersonalSchedule]
//        let cellHeight: CGFloat
//        
//        var body: some View {
//            VStack {
//                let weekday = Calendar.current.component(.weekday, from: date)
//                            let dayColor: Color = {
//                                if weekday == 1 { return .red }
//                                else if weekday == 7 { return .blue }
//                                else { return .black }
//                            }()
//                Text("\(Calendar.current.component(.day, from: date))")
//                    .foregroundColor(isCurrentMonth ? dayColor : .gray)
//                
//                if !schedules.isEmpty {
//                    VStack {
//                        
//                        ForEach(schedules) { schedule in
//                            
//                            Text(schedule.name)
//                                .font(.caption)
//                                .frame(maxWidth: .infinity)
//                                .foregroundColor(.white)
//                                .padding(4)
//                                .background(schedule.color)
//                                .cornerRadius(5)
//                                .lineLimit(1)
//                        }
//                    }
//                }
//                Spacer()
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: cellHeight)
//            .border(Color.gray)
//        }
//    }
//    
//    private struct CalendarHeaderView: View {
//        @StateObject private var viewModel = FirestoreViewModel()
//        @Binding var currentMonth: Date
//        @Binding var selectedYear: Int
//        @Binding var selectedMonth: Int
//        let user: User
//        
//        @State private var isShowingDatePicker = false
//        @State private var isChoosing = false
//                
//        private func formattedDate(_ date: Date) -> String {
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "ko_KR")
//            formatter.dateFormat = "yyyy년 M월"
//            return formatter.string(from: date)
//        }
//        
//        var body: some View {
//            HStack {
//                Image(systemName: "calendar")
//                    .font(.largeTitle)
//                    //.foregroundColor(.green)
//                VStack(alignment: .leading) {
//                    HStack {
//                        Text(formattedDate(currentMonth))
//                            .font(.headline)
//                            .bold()
//                        Button(action: {
//                            isShowingDatePicker.toggle()
//                        }) {
//                            Image(systemName: "chevron.down.square.fill")
//                                .font(.headline)
//                        }
//                        .sheet(isPresented: $isShowingDatePicker) {
//                            VStack {
//                                HStack {
//                                    Picker("연도 선택", selection: $selectedYear) {
//                                        ForEach((selectedYear - 100)...(selectedYear + 100), id: \.self) { year in
//                                                            Text("\(String(format: "%d", year))년").tag(year)
//                                                        }
//                                    }
//                                    .pickerStyle(WheelPickerStyle())
//                                    .frame(width: 120)
//                                    
//                                    Picker("월 선택", selection: $selectedMonth) {
//                                        ForEach(1...12, id: \.self) { month in
//                                            Text("\(month)월").tag(month)
//                                        }
//                                    }
//                                    .pickerStyle(WheelPickerStyle())
//                                    .frame(width: 120)
//                                }
//                                
//                                Button("확인") {
//                                    if let newDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1)) {
//                                        currentMonth = newDate
//                                    }
//                                    isShowingDatePicker = false
//                                }
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue)
//                                .foregroundColor(.white)
//                                .cornerRadius(10)
//                                .padding(.top, 10)
//                                
//                            }
//                            .padding()
//                            .presentationDetents([.medium])
//                        }
//                    }
//                    
//                    Text(user.userID)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//                
//                Spacer()
//                NavigationLink(destination: MainCalendarView(user: user)) {
//                    Image(systemName: "togglepower")
//                }
//                .onDisappear {
//                    viewModel.fetchPersonalSchedules()
//                    viewModel.fetchUsers()
//                }
//
//                                Button(action: {}) {
//                                    Image(systemName: "star")
//                                }
//                                Button(action: {}) {
//                                    Image(systemName: "bubble.right")
//                                }
//                
//            }
//            .padding()
//        }
//    }
//    private struct WeekdayHeaderView: View {
//        private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
//        
//        var body: some View {
//            HStack {
//                ForEach(weekDays, id: \.self) { day in
//                    Text(day)
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                        .frame(maxWidth: .infinity)
//                }
//            }
//        }
//    }
//    
//    private struct AddScheduleButton: View {
//        @StateObject private var viewModel = FirestoreViewModel()
//        @Binding var isShowingSheet: Bool
//        @Binding var selectedDate: Date
//        let user: User
//        
//        var body: some View {
//            VStack {
//                Spacer()
//                Button(action: { isShowingSheet.toggle() }) {
//                    Image(systemName: "plus.circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .foregroundStyle(.white)
//                        .frame(width: 50, height: 50)
//                        .padding()
//                }
//                .frame(width: 80, height: 80)
//                .background(Color.gray.opacity(0.3))
//                .cornerRadius(40)
//                .padding(.bottom, 20)
//                .sheet(isPresented: $isShowingSheet, onDismiss: {
//                    viewModel.fetchPersonalSchedules()
//                }) {
//                    AddPersonalScheduleView(user: user, selectedDate: selectedDate)
//                }
//            }
//        }
//    }
//    
//    func getFirstWeekday(of year: Int, month: Int) -> Int {
//        let calendar = Calendar.current
//        
//        // 해당 월의 1일 날짜 구하기
//        let firstDate = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
//        
//        // 해당 월의 1일이 있는 주의 일요일 날짜 구하기
//        let firstSunday = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: firstDate))!
//        
//        // 1일과 그 주의 일요일 사이의 일수 차이 구하기
//        let difference = calendar.dateComponents([.day], from: firstSunday, to: firstDate).day ?? 0
//        
//        return difference
//    }
//    
//    // 이전 달의 마지막 날짜들을 가져오는 함수
//    func getLastDaysOfPreviousMonth(year: Int, month: Int, count: Int) -> [Int] {
//        let calendar = Calendar.current
//        let components = DateComponents(year: year, month: month, day: 1)
//        
//        // 이전 달의 마지막 날 구하기
//        let firstDayOfMonth = calendar.date(from: components)!
//        let lastDayOfPrevMonth = calendar.date(byAdding: .day, value: -1, to: firstDayOfMonth)!
//        
//        let lastDay = calendar.component(.day, from: lastDayOfPrevMonth)
//        
//        // 필요한 만큼의 이전 달 날짜 배열 만들기
//        return (0..<count).map { lastDay - count + $0 + 1 }
//    }
//    
//    private func getDaysInMonth(for date: Date) -> [Date] {
//        let calendar = Calendar.current
//        
//        // 해당 월의 첫날과 마지막날 구하기
//        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
//              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
//              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
//            return []
//        }
//        
//        // 첫 주부터 마지막 주까지의 모든 날짜를 배열로 만들기
//        var result: [Date] = []
//        var currentDate = monthFirstWeek.start
//        
//        while currentDate < monthLastWeek.end {
//            result.append(currentDate)
//            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
//        }
//        
//        return result
//    }
//    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
//        Calendar.current.isDate(date1, inSameDayAs: date2)
//    }
//    
//    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
//        let calendar = Calendar.current
//        return calendar.component(.month, from: date1) == calendar.component(.month, from: date2) &&
//        calendar.component(.year, from: date1) == calendar.component(.year, from: date2)
//    }
//    
//    private func getSchedulesForDate(_ date: Date) -> [PersonalSchedule] {
//        viewModel.personalSchedule.filter { schedule in
//            schedule.schedule.contains { timeSlot in
//                Calendar.current.isDate(date, inSameDayAs: timeSlot.startTime) ||
//                Calendar.current.isDate(date, inSameDayAs: timeSlot.endTime) ||
//                (date >= timeSlot.startTime && date <= timeSlot.endTime)
//            }
//        }
//    }
//    private func changeMonth(by value: Int) {
//        withAnimation {
//            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
//                currentMonth = newDate
//            }
//        }
//    }
//    func isDateInRange(date: Date, startDate: Date, endDate: Date, year: Int, month: Int) -> Bool {
//        let calendar = Calendar.current
//        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
//        let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
//        let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
//        guard let day = dateComponents.day,
//              let startDay = startComponents.day,
//              let endDay = endComponents.day else {
//            return false
//        }
//        return (dateComponents.year == year && dateComponents.month == month) &&
//        (startComponents.year == year && startComponents.month == month && startDay <= day) &&
//        (endComponents.year == year && endComponents.month == month && endDay >= day)
//    }
//    func convertToDate(_ value: Any?) -> Date {
//        if let timestamp = value as? Timestamp {
//            return timestamp.dateValue()
//        } else if let date = value as? Date {
//            return date
//        }
//        return Date()
//    }
//}
