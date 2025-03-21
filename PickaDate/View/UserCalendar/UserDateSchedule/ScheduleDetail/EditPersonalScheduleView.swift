//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct EditUserScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    let schedule: PDUserSchedule
    @State private var currentDate = Date()
    
    @State private var title: String
    @State private var content: String
    @State private var selectedGroups: Set<String>
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: String
    @State private var isAllDay: Bool = false
    
    init(schedule: PDUserSchedule) {
        self.schedule = schedule
        
        _title = State(initialValue: schedule.title)
        _content = State(initialValue: schedule.content)
        _selectedGroups = State(initialValue: Set(schedule.groupIDs))
        if let firstSchedule = schedule.schedules.first {
            _startDate = State(initialValue: firstSchedule.startTime)
            _endDate = State(initialValue: firstSchedule.endTime)
            _isAllDay = State(initialValue: firstSchedule.isAllDay)
        } else {
            _startDate = State(initialValue: Date())
            _endDate = State(initialValue: Date())
            _isAllDay = State(initialValue: false)
        }
        
        _selectedColor = State(initialValue: schedule.userScheduleColor)
    }
    
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
            Form {
                Section(header: Text("일정 정보").foregroundColor(.black)) {
                    TextField("일정 이름", text: $title)
                        .foregroundColor(.black)
                    
                    TextField("내용", text: $content)
                        .foregroundColor(.black)
                    
                }
                
                Section {
                    Toggle("종일", isOn: $isAllDay)
                        .foregroundColor(.black)
                        .onChange(of: isAllDay) {
                            if isAllDay {
                                startDate = Calendar.current.startOfDay(for: startDate)
                                endDate = Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399)
                            }
                        }
                }
                
                Section {
                    DatePicker("시작 날짜", selection: $startDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                        .environment(\.timeInterval, 600)
                    
                    DatePicker("종료 날짜", selection: $endDate, displayedComponents: isAllDay ? .date : [.date, .hourAndMinute])
                        .environment(\.timeInterval, 600)
                } header: {
                    Text("날짜 설정")
                        .foregroundColor(.black)
                }
                
                Section(header: Text("공유 그룹 선택").foregroundColor(.black)) {
                    MultiSelectGroupView(userGroups: userViewModel.currentUser?.joinedGroups ?? [], selectedGroups: $selectedGroups)
                }
                
                Section(header: Text("색상 선택").foregroundColor(.black)) {
                    Picker("색상", selection: $selectedColor) {
                        ForEach(colors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(colorMap[color, default: .green])
                                    .frame(width: 15, height: 15)
                                Text(color.capitalized)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .navigationTitle("일정 편집")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("수정") {
                        editSchedule()
                    }
                    .foregroundColor(.black)
                }
            }
            .onAppear {
                userViewModel.fetchUserSchedules()
            }
        }
        
        
    }
    private func editSchedule() {
        guard !title.isEmpty, !content.isEmpty else { return }
        guard userViewModel.currentUser != nil else { return }

        let calendar = Calendar.current
        let finalStartDate = isAllDay ? calendar.startOfDay(for: startDate) : startDate
        let finalEndDate = isAllDay ? calendar.startOfDay(for: endDate).addingTimeInterval(86399) : endDate

        var updatedSchedule: [UserTimeSlot] = []

        if isAllDay {
            var currentDate = finalStartDate
            while currentDate <= finalEndDate {
                let dayStart = calendar.startOfDay(for: currentDate)
                let dayEnd = calendar.startOfDay(for: currentDate).addingTimeInterval(86399)

                updatedSchedule.append(UserTimeSlot(startTime: dayStart, endTime: dayEnd, isAllDay: true))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        } else {
            updatedSchedule.append(UserTimeSlot(startTime: finalStartDate, endTime: finalEndDate, isAllDay: false))
        }

        let updatedGroupIDArray = selectedGroups.isEmpty ? [] : Array(selectedGroups)

        guard let scheduleID = schedule.id else {
            print("오류: schedule.id가 nil입니다.")
            return
        }

        userViewModel.updateUserSchedule(
            scheduleID: scheduleID,
            title: title,
            content: content,
            groupIDs: updatedGroupIDArray,
            schedules: updatedSchedule,
            userScheduleColor: selectedColor
        )

        presentationMode.wrappedValue.dismiss()
    }
}
