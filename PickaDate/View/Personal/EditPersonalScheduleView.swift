//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct EditPersonalScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = FirestoreViewModel()
    
    let user: User
    let schedule: PersonalSchedule
    @State private var currentDate = Date()
    
    @State private var name: String
    @State private var content: String
    @State private var selectedGroups: Set<String>
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: String
    @State private var isAllDay: Bool = false
    
    init(user: User, schedule: PersonalSchedule) {
        self.user = user
        self.schedule = schedule
        
        _name = State(initialValue: schedule.name)
        _content = State(initialValue: schedule.content)
        _selectedGroups = State(initialValue: Set(schedule.groupID))
        if let firstSchedule = schedule.schedule.first {
            _startDate = State(initialValue: firstSchedule.startTime)
            _endDate = State(initialValue: firstSchedule.endTime)
            _isAllDay = State(initialValue: firstSchedule.isAllDay)
        } else {
            _startDate = State(initialValue: Date())
            _endDate = State(initialValue: Date())
            _isAllDay = State(initialValue: false)
        }
        
        _selectedColor = State(initialValue: schedule.personalColor)
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
                    TextField("일정 이름", text: $name)
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
                                    MultiSelectGroupView(userGroups: user.joinGroup, selectedGroups: $selectedGroups)
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
                viewModel.fetchPersonalSchedules()
            }
        }
        
        
    }
    private func editSchedule() {
        guard !name.isEmpty, !content.isEmpty else { return }

        let calendar = Calendar.current
        let finalStartDate = isAllDay ? calendar.startOfDay(for: startDate) : startDate
        let finalEndDate = isAllDay ? calendar.startOfDay(for: endDate).addingTimeInterval(86399) : endDate

        var updatedSchedule: [TimeSlotPersonal] = []

        if isAllDay {
            var currentDate = finalStartDate
            while currentDate <= finalEndDate {
                let dayStart = calendar.startOfDay(for: currentDate)
                let dayEnd = calendar.startOfDay(for: currentDate).addingTimeInterval(86399)

                updatedSchedule.append(TimeSlotPersonal(startTime: dayStart, endTime: dayEnd, isAllDay: true))
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
            }
        } else {
            updatedSchedule.append(TimeSlotPersonal(startTime: finalStartDate, endTime: finalEndDate, isAllDay: false))
        }

        let updatedGroupIDArray = selectedGroups.isEmpty ? [] : Array(selectedGroups)

        guard let scheduleID = schedule.id else {
            print("오류: schedule.id가 nil입니다.")
            return
        }

        viewModel.updatePersonalSchedule(
            scheduleID: scheduleID,
            userID: user.userID,
            name: name,
            content: content,
            groupID: updatedGroupIDArray,
            schedule: updatedSchedule,
            personalColor: selectedColor
        )

        presentationMode.wrappedValue.dismiss()
    }

}
//struct MultiSelectGroupView: View {
//    let userGroups: [String]
//    @Binding var selectedGroups: Set<String>
//    
//    var body: some View {
//        List {
//            ForEach(userGroups, id: \.self) { group in
//                HStack {
//                    Text(group)
//                    Spacer()
//                    if selectedGroups.contains(group) {
//                        Image(systemName: "checkmark.circle.fill")
//                            .foregroundColor(.blue)
//                    } else {
//                        Image(systemName: "circle")
//                            .foregroundColor(.gray)
//                    }
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    if selectedGroups.contains(group) {
//                        selectedGroups.remove(group)
//                    } else {
//                        selectedGroups.insert(group)
//                    }
//                }
//            }
//        }
//    }
//}
