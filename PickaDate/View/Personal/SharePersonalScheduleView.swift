//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct SharePersonalScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FirestoreViewModel()
    
    let user: User
    let schedule: PersonalSchedule
    @State private var selectedDates: [Date] = []
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
                    ForEach(selectedDates, id: \.self) { date in
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
            }
            .navigationBarItems(trailing: Button("닫기") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    private func initializeSelectedDates() {
        selectedDates = schedule.schedule.map { Calendar.current.startOfDay(for: $0.startTime) }
    }
    private struct DayCell: View {
        let date: Date
        @Binding var selectedDates: [Date]
        
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
        if selectedDates.contains(date) {
            selectedDates.removeAll { $0 == date }
        } else {
            selectedDates.append(date)
        }
    }
    private func changeMonth(by value: Int) {
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
            currentMonth = newDate
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
        for date in selectedDates {
            let newTimeSlots = schedule.schedule.map { timeSlot -> TimeSlotPersonal in
                let originalStartTime = timeSlot.startTime
                let timeOffset = originalStartTime.timeIntervalSince(Calendar.current.startOfDay(for: originalStartTime))
                
                let newStartTime = Calendar.current.startOfDay(for: date).addingTimeInterval(timeOffset)
                let newEndTime = newStartTime.addingTimeInterval(timeSlot.endTime.timeIntervalSince(originalStartTime))
                
                return TimeSlotPersonal(startTime: newStartTime, endTime: newEndTime, isAllDay: timeSlot.isAllDay)
            }
            
            viewModel.addPersonalSchedule(
                userID: schedule.userID,
                name: schedule.name,
                content: schedule.content,
                groupID: schedule.groupID,
                schedule: newTimeSlots,
                personalColor: schedule.personalColor
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
