//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct CopyUserScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    let schedule: PDUserSchedule
    @State private var selectedDates: Set<Date> = []
    @State private var currentMonth: Date = Date()
    
    let calendar = Calendar.current
    
    let colors: [String] = ["red", "orange", "yellow", "green", "blue", "purple", "brown"]
    
    let colorMap: [String: Color] = [
        "red": .red,
        "orange": .orange,
        "yellow": .yellow,
        "green": .green,
        "blue": .blue,
        "purple": .purple,
        "brown": .brown
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                    Button(action: { changeMonth(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Text(dateFormatter.string(from: currentMonth))
                        .font(.title2)
                        .bold()
                    Spacer()
                    Button(action: { changeMonth(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                let days = getDaysInMonth(for: currentMonth)
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { date in
                        DayCell(date: date, selectedDates: $selectedDates)
                            .onTapGesture {
                                toggleDateSelection(date)
                            }
                    }
                }
                .padding()
                
                List {
                    ForEach(selectedDates.sorted(), id: \.self) { date in
                        HStack {
                            Text(selectedDateFormatter.string(from: date))
                            Spacer()
                        }
                    }
                }
                
                Button(action: copyScheduleToSelectedDates) {
                    Text("복사")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
            }
            .onAppear {
                initializeSelectedDates()
                if let firstDate = schedule.schedule.first?.startTime {
                    currentMonth = firstDate
                }
            }
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    private func initializeSelectedDates() {
        let existingDates = schedule.schedule.map { Calendar.current.startOfDay(for: $0.startTime) }
        selectedDates.formUnion(existingDates)
    }
    
    private struct DayCell: View {
        let date: Date
        @Binding var selectedDates: Set<Date>
        
        var isSelected: Bool {
            selectedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
        }
        
        
        var body: some View {
            VStack {
                Text("\(Calendar.current.component(.day, from: date))")
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(
                        isSelected ? AnyView(Circle().fill(Color.blue).opacity(0.3)) : AnyView(EmptyView())
                    )
                
                
            }
        }
    }
    private func toggleDateSelection(_ date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        selectedDates.formSymmetricDifference([normalizedDate])
        print("토글시 - \(selectedDates)")
    }
    
    
    private func changeMonth(by value: Int) {
        guard let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) else { return }
        withAnimation {
            currentMonth = newDate
            print("changeMonth: \(currentMonth)")
        }
    }
    
    
    private func getDaysInMonth(for date: Date) -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return []
        }
        
        var days: [Date] = []
        var currentDate = firstWeek.start
        
        while currentDate < lastWeek.end {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return days
    }
    private func copyScheduleToSelectedDates() {
        guard userViewModel.currentUser != nil else { return }
        
        let initialDates = schedule.schedule.map { Calendar.current.startOfDay(for: $0.startTime) }
        print("initialDates: \(initialDates)")
        let newDates = selectedDates.sorted().filter { date in
            !initialDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) })
        }
        print("newDates: \(newDates)")
        for date in newDates {
            let newTimeSlots = schedule.schedule.map { timeSlot -> UserTimeSlot in
                let originalStartTime = timeSlot.startTime
                let timeOffset = originalStartTime.timeIntervalSince(Calendar.current.startOfDay(for: originalStartTime))
                
                let newStartTime = Calendar.current.startOfDay(for: date).addingTimeInterval(timeOffset)
                let newEndTime = newStartTime.addingTimeInterval(timeSlot.endTime.timeIntervalSince(originalStartTime))
                
                return UserTimeSlot(startTime: newStartTime, endTime: newEndTime, isAllDay: timeSlot.isAllDay)
            }
            
            userViewModel.addUserSchedule(
                title: schedule.title,
                content: schedule.content,
                groupIDs: schedule.groupIDs,
                schedule: newTimeSlots,
                userScheduleColor: schedule.userScheduleColor
            )
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        return formatter
    }
    
    private var selectedDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter
    }
}
