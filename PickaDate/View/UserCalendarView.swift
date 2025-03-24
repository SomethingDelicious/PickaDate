//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct UserCalendarView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isShowingDetailView = false
    @State private var selectedDate = Date() //일
    @State private var currentMonth: Date = Date() //월
    @State var selectedCalendars: Set<String> = ["개인 캘린더"]
    
    private var year: Int {
        Calendar.current.component(.year, from: selectedDate)
    }
    
    private var month: Int {
        Calendar.current.component(.month, from: selectedDate)
    }
    
    private var days: [Date] {
        getDaysInMonth(for: currentMonth)
    }
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedMonth = Calendar.current.component(.month, from: Date())
    
    var body: some View {
        NavigationView {
            VStack {
                CalendarHeaderView(
                    currentMonth: $currentMonth,
                    selectedYear: $selectedYear,
                    selectedMonth: $selectedMonth,
                    user: userViewModel.currentUser,
                    selectedCalendars: $selectedCalendars
                )
                WeekdayHeaderView()
                let firstWeekday = Calendar.current.component(.weekday, from: days.first ?? Date()) - 1
                let totalCells = firstWeekday + days.count
                let numRows = Int(ceil(Double(totalCells) / 7.0))
                let cellHeight = 570 / CGFloat(numRows)
                
                ZStack {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7),
                        spacing: 0
                    ) {
                        ForEach(days, id: \.self) { date in
                            DayCell(
                                date: date,
                                isSelected: isSameDay(date, selectedDate),
                                isCurrentMonth: isSameMonth(date, currentMonth),
                                cellHeight: cellHeight
                            )
                            // GeometryReader로 각 날짜 셀의 프레임 정보를 캡처하여 PreferenceKey에 저장
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .anchorPreference(
                                            key: DayCellBoundsKey.self,
                                            value: .bounds
                                        ) { anchor in
                                            [date.dayOnly: anchor]
                                        }
                                }
                            )
                            .background(selectedDate == date ? Color.gray.opacity(0.3) : Color.clear)
                            .onTapGesture {
                                if selectedDate == date {
                                    isShowingDetailView = true
                                } else {
                                    selectedDate = date
                                }
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
                    // 일정 블록 그리기: 날짜 셀 위에 overlay로 이벤트(일정) 블록을 표시합니다.
                    .overlayPreferenceValue(DayCellBoundsKey.self) { dayCellAnchors in
                        GeometryReader { proxy in
                            // 달력 전체 주 수에 따라 하루에 표시할 최대 일정 개수 결정
                            let firstWeekday = Calendar.current.component(.weekday, from: days.first ?? Date()) - 1
                            let totalCells = firstWeekday + days.count
                            let numRows = Int(ceil(Double(totalCells) / 7.0))
                            let maxEventsPerDay: Int = (numRows == 5) ? 3 : ((numRows == 6) ? 2 : 3)
                            
                            // 날짜 숫자 아래쪽에 이벤트 블록이 위치하도록 오프셋 지정
                            let dayNumberOffset: CGFloat = 30
                            // 이벤트 블록의 높이 및 트랙 간격 지정
                            let blockHeight: CGFloat = 20
                            let trackSpacing: CGFloat = blockHeight + 4
                            
                            // 개인 일정과 그룹 일정을 Event 배열로 생성하고, 트랙 배치 함수로 정렬
                            let allEvents = createEvents()
                            let arrangedEvents = arrangeEvents(allEvents)
                            
                            ForEach(arrangedEvents) { event in
                                // 하루에 표시할 최대 개수보다 트랙 인덱스가 높으면 표시하지 않음
                                if event.trackIndex < maxEventsPerDay {
                                    if let startAnchor = dayCellAnchors[event.startDate.dayOnly],
                                       let endAnchor   = dayCellAnchors[event.endDate.dayOnly] {
                                        let startRect = proxy[startAnchor]
                                        let endRect   = proxy[endAnchor]
                                        
                                        // 이벤트 블록의 좌측 위치와 전체 너비 계산
                                        let x = min(startRect.minX, endRect.minX)
                                        let width = abs(endRect.maxX - startRect.minX)
                                        
                                        // y 좌표: 날짜 셀 상단에서 dayNumberOffset 이후, 트랙 인덱스에 따른 위치 조정
                                        let y = startRect.minY + dayNumberOffset + (blockHeight / 2) + (CGFloat(event.trackIndex) * trackSpacing)
                                        
                                        // ZStack으로 이벤트 블록을 구성
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(event.color)
                                            Text(event.title)
                                                .font(.caption)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                                .padding(.horizontal, 4)
                                        }
                                        .frame(width: width, height: blockHeight)
                                        .position(x: x + width/2, y: y)
                                        .transition(.opacity)
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
            .sheet(isPresented: $isShowingDetailView, onDismiss: {
                userViewModel.fetchUserSchedules()
            }) {
                let selectedSchedules = userViewModel.userSchedules.filter { schedule in
                    schedule.schedules.contains { timeSlot in
                        let startDate = convertToDate(timeSlot.startTime)
                        let endDate = convertToDate(timeSlot.endTime)
                        return isDateInRange(
                            date: selectedDate,
                            startDate: startDate,
                            endDate: endDate,
                            year: year,
                            month: month
                        )
                    }
                }
                UserDateScheduleView(
                    selectedDate: selectedDate,
                    userSchedules: selectedSchedules
                )
            }
            .onAppear {
                userViewModel.fetchUserSchedules()
            }
            
        }
        
        
    }
    
    
}

// MARK: - 부속 struct 및 extension
// Event: 개인 또는 그룹 일정을 단일 이벤트로 표현하며, createdAt 정보를 포함합니다.
// ArrangedEvent: 이벤트를 겹치지 않도록 트랙(줄)을 배정한 후 실제 그릴 때 사용하는 구조체입니다.
struct Event: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let color: Color
    let createdAt: Date
}

struct ArrangedEvent: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let color: Color
    let trackIndex: Int  // 같은 날짜 내에서 겹치는 이벤트가 있을 때, 트랙 번호(위쪽이 낮은 번호)
}

// 날짜를 연/월/일 단위로만 추출하기 위한 확장입니다.
extension Date {
    var dayOnly: Date {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: self)
        return Calendar.current.date(from: comps)!
    }
}

// 각 날짜 셀의 화면상 위치(Anchor<CGRect>) 정보를 상위 뷰로 전달하기 위한 PreferenceKey입니다.
struct DayCellBoundsKey: PreferenceKey {
    static var defaultValue: [Date: Anchor<CGRect>] = [:]
    
    static func reduce(value: inout [Date: Anchor<CGRect>],
                       nextValue: () -> [Date: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - 부속 struct 및 extension2
private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isCurrentMonth: Bool
    let cellHeight: CGFloat
    
    var body: some View {
        VStack {
            let weekday = Calendar.current.component(.weekday, from: date)
            let dayColor: Color = {
                if weekday == 1 { return .red }
                else if weekday == 7 { return .blue }
                else { return .black }
            }()
            
            Text("\(Calendar.current.component(.day, from: date))")
                .foregroundColor(isCurrentMonth ? dayColor : .gray)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: cellHeight)
    }
}

private struct CalendarHeaderView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @Binding var currentMonth: Date
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    let user: PDUser?
    @State private var isShowingDatePicker = false
    @State private var isChoosing = false
    @Binding var selectedCalendars: Set<String>
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: "calendar")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(formattedDate(currentMonth))
                        .font(.headline)
                        .bold()
                    Button(action: {
                        isShowingDatePicker.toggle()
                    }) {
                        Image(systemName: "chevron.down.square.fill")
                            .font(.headline)
                    }
                    .sheet(isPresented: $isShowingDatePicker) {
                        VStack {
                            HStack {
                                Picker("연도 선택", selection: $selectedYear) {
                                    ForEach((selectedYear - 100)...(selectedYear + 100), id: \.self) { year in
                                        Text("\(year)년").tag(year)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 120)
                                
                                Picker("월 선택", selection: $selectedMonth) {
                                    ForEach(1...12, id: \.self) { month in
                                        Text("\(month)월").tag(month)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .frame(width: 120)
                            }
                            
                            Button("확인") {
                                if let newDate = Calendar.current.date(
                                    from: DateComponents(
                                        year: selectedYear,
                                        month: selectedMonth,
                                        day: 1
                                    )
                                ) {
                                    currentMonth = newDate
                                    selectedYear = Calendar.current.component(.year, from: newDate)
                                    selectedMonth = Calendar.current.component(.month, from: newDate)
                                }
                                isShowingDatePicker = false
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 10)
                        }
                        .padding()
                        .presentationDetents([.medium])
                    }
                }
                Text(user?.userName ?? "")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            
            Button(action: {
                isChoosing.toggle()
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .sheet(isPresented: $isChoosing, onDismiss: {
            userViewModel.fetchUserSchedules()
        }) {
            if let user = user {
                 ChooseShowingCalendarView(
                     user: user,
                     selectedCalendars: $selectedCalendars
                 )
             } else {
                 Text("사용자 정보를 불러오는 중...")
                     .padding()
             }
        }
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

// 날짜 관련 기능, 일정 생성 및 트랙 배치 등 주요 로직들을 여기에 정의합니다.
extension UserCalendarView {
    
    // (A) 개인 일정과 그룹 일정을 Event 배열로 변환
    // Firestore의 Timestamp를 Date로 변환하는 convertToDate 함수를 활용합니다.
    func createEvents() -> [Event] {
        var result: [Event] = []
        
        if selectedCalendars.contains("개인 캘린더") {
            for schedule in userViewModel.userSchedules {
                for timeSlot in schedule.schedules {
                    let start = convertToDate(timeSlot.startTime)
                    let end   = convertToDate(timeSlot.endTime)
                    
                    let event = Event(
                        title: schedule.title,
                        startDate: start,
                        endDate: end,
                        color: schedule.color,
                        createdAt: convertToDate(schedule.createdAt)
                    )
                    result.append(event)
                }
            }
        }
        
        for schedule in dummyGroupSchedules {
            if selectedCalendars.contains(schedule.groupID) {
                let timeSlot = schedule.schedule
                    let start = timeSlot.startTime
                    let end   = timeSlot.endTime
                    let color = Color.self
                    
                    let event = Event(
                        title: schedule.title,
                        startDate: start,
                        endDate: end,
                        color: schedule.color,
                        createdAt: schedule.createdAt
                    )
                    result.append(event)
                
            }
        }
        
        return result
    }
    
    // (B) 이벤트를 겹치지 않게 트랙별로 배치하고 정렬 (startDate, createdAt 순)
    func arrangeEvents(_ events: [Event]) -> [ArrangedEvent] {
        // 같은 날짜에서는 startDate, 그리고 startDate가 같으면 createdAt 순으로 정렬
        let sorted = events.sorted { e1, e2 in
            if Calendar.current.isDate(e1.startDate, inSameDayAs: e2.startDate) {
                if e1.startDate == e2.startDate {
                    return e1.createdAt < e2.createdAt
                } else {
                    return e1.startDate < e2.startDate
                }
            } else {
                return e1.startDate < e2.startDate
            }
        }
        
        var tracks: [[Event]] = []  // 각 트랙에 배치된 이벤트 배열
        var arranged: [ArrangedEvent] = []  // 최종적으로 배치된 이벤트 배열
        
        // 정렬된 이벤트를 순회하며 각 이벤트를 겹치지 않는 트랙에 배치
        for e in sorted {
            var placed = false
            for (trackIndex, track) in tracks.enumerated() {
                if !track.contains(where: { isOverlap($0, e) }) {
                    tracks[trackIndex].append(e)
                    arranged.append(
                        ArrangedEvent(
                            title: e.title,
                            startDate: e.startDate,
                            endDate: e.endDate,
                            color: e.color,
                            trackIndex: trackIndex
                        )
                    )
                    placed = true
                    break
                }
            }
            // 기존 트랙에 배치되지 않았다면 새 트랙 생성
            if !placed {
                tracks.append([e])
                let newTrackIndex = tracks.count - 1
                arranged.append(
                    ArrangedEvent(
                        title: e.title,
                        startDate: e.startDate,
                        endDate: e.endDate,
                        color: e.color,
                        trackIndex: newTrackIndex
                    )
                )
            }
        }
        
        return arranged
    }
    
    // 두 일정이 시간 범위에서 겹치는지 여부를 판단합니다.
    func isOverlap(_ e1: Event, _ e2: Event) -> Bool {
        !(e1.endDate < e2.startDate || e1.startDate > e2.endDate)
    }
    
    private func changeMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.5)) { //수정
            if let newDate = Calendar.current.date(byAdding: .month, value: value, to: currentMonth) {
                currentMonth = newDate
                selectedYear = Calendar.current.component(.year, from: newDate)
                selectedMonth = Calendar.current.component(.month, from: newDate)
            }
        }
    }
    
    private func getDaysInMonth(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek  = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }
        
        var result: [Date] = []
        var currentDate = monthFirstWeek.start
        
        while currentDate < monthLastWeek.end {
            result.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        return result
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        Calendar.current.isDate(date1, inSameDayAs: date2)
    }
    
    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: date1) == calendar.component(.month, from: date2)
        && calendar.component(.year, from: date1) == calendar.component(.year, from: date2)
    }
    
    func isDateInRange(date: Date, startDate: Date, endDate: Date, year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let dateComponents  = calendar.dateComponents([.year, .month, .day], from: date)
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endComponents   = calendar.dateComponents([.year, .month, .day], from: endDate)
        
        guard let day = dateComponents.day,
              let startDay = startComponents.day,
              let endDay = endComponents.day else {
            return false
        }
        
        return (dateComponents.year == year && dateComponents.month == month)
        && (startComponents.year == year && startComponents.month == month && startDay <= day)
        && (endComponents.year == year && endComponents.month == month && endDay >= day)
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

let dummyGroupSchedules: [PDGroupSchedule] = []
