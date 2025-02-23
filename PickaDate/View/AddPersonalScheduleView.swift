//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct AddPersonalScheduleView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = FirestoreViewModel()
    
    let user: String
    let selectedDate: Date
    
    @State private var name: String = ""
    @State private var content: String = ""
    @State private var groupIDInput: String = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var selectedColor: String = "green"
    
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
    
    init(user: String, selectedDate: Date) {
        self.user = user
        self.selectedDate = selectedDate
        self._startDate = State(initialValue: selectedDate)
        self._endDate = State(initialValue: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("일정 정보").foregroundColor(.black)) {
                    TextField("일정 이름", text: $name)
                        .foregroundColor(.black)
                    
                    TextField("내용", text: $content)
                        .foregroundColor(.black)
                    
                }
                
                Section(header: Text("날짜 설정").foregroundColor(.black)) {
                    DatePicker("시작 날짜", selection: $startDate, displayedComponents: .date)
                    DatePicker("종료 날짜", selection: $endDate, displayedComponents: .date)
                }
                
                Section(header: Text("공유 그룹 (쉼표로 구분)").foregroundColor(.black)) {
                    TextField("그룹 ID (예: group1, group2)", text: $groupIDInput)
                        .foregroundColor(.black)
                    
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
                        dismiss()
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
        }
    }
    private func addSchedule() {
        guard !name.isEmpty, !content.isEmpty else { return }
        
        let schedule = [TimeSlotPersonal(startTime: startDate, endTime: endDate)]
        
        let groupIDArray = groupIDInput.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        viewModel.addPersonalSchedule(userID: user, name: name, content: content, groupID: groupIDArray, schedule: schedule, personalColor: selectedColor)
        
        dismiss()
    }
}
