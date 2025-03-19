//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

private struct TimeIntervalKey: EnvironmentKey {
    static let defaultValue: Int = 60
}

extension EnvironmentValues {
    var timeInterval: Int {
        get { self[TimeIntervalKey.self] }
        set { self[TimeIntervalKey.self] = newValue }
    }
}

struct AddUserScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    let selectedDate: Date
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedGroups: Set<String> = []
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: String = "green"
    @State private var isAllDay: Bool = false
    
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
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
        self._startDate = State(initialValue: selectedDate)
        self._endDate = State(initialValue: selectedDate)
    }
    
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
                
                
                
                Section(header: Text("공유할 그룹 선택").foregroundColor(.black)) {
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
            .navigationTitle("새 일정 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        addSchedule()
                    }
                    .foregroundColor(.black)
                }
            }
            .onAppear {
                Task {
                    try await userViewModel.fetchCurrentUser()
                }
            }
        }
        
        
    }
    private func addSchedule() {
        guard !title.isEmpty, !content.isEmpty else { return }
        guard userViewModel.currentUser != nil else { return }
        
        let finalStartDate = isAllDay ? Calendar.current.startOfDay(for: startDate) : startDate
        let finalEndDate = isAllDay ? Calendar.current.startOfDay(for: endDate).addingTimeInterval(86399) : endDate

        let schedule = [UserTimeSlot(startTime: finalStartDate, endTime: finalEndDate)]
        
        let selectedGroupArray = selectedGroups.isEmpty ? [] : Array(selectedGroups)

        userViewModel.addUserSchedule(title: title, content: content, groupIDs: selectedGroupArray, schedule: schedule, userScheduleColor: selectedColor)
        
        presentationMode.wrappedValue.dismiss()
    }
}

struct MultiSelectGroupView: View {
    let userGroups: [String]
    @Binding var selectedGroups: Set<String>
    
    var body: some View {
        List {
            ForEach(userGroups, id: \.self) { group in
                HStack {
                    Text(group)
                    Spacer()
                    if selectedGroups.contains(group) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.gray)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedGroups.contains(group) {
                        selectedGroups.remove(group)
                    } else {
                        selectedGroups.insert(group)
                    }
                }
            }
        }
    }
}
