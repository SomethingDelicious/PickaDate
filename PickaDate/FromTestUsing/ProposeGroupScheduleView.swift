//
//  ProposeGroupScheduleView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI

// 날짜와 시간 정보를 포함하는 구조체
struct ScheduleDateItem: Identifiable {
    var id = UUID()
    var date: Date
    var isAllDay: Bool
    var startTime: Date
    var endTime: Date
}

struct ProposeGroupScheduleView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var groupViewModel = GroupViewModel()
    @StateObject private var scheduleViewModel = GroupCalendarViewModel()
    
    let userID: String  // 현재 사용자 ID
    let groupID: String // 그룹 ID
    
    // 일정 정보 변수
    @State private var groupName: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    
    // 시간 설정 변수
    @State private var isTimeFixed: Bool = false
    @State private var isAllDay: Bool = false
    @State private var startTime = Date()
    @State private var endTime = Date().addingTimeInterval(3600)
    
    // 날짜 선택 변수
    @State private var selectedDates: [Date] = []
    @State private var showingDatePicker: Bool = false
    @State private var scheduleDateItems: [ScheduleDateItem] = []
    
    // 색상 선택 변수
    @State private var selectedColor: String = "blue"
    @State private var isLoading = false
    
    // 색상 선택 옵션
    let colors = ["red", "orange", "yellow", "green", "blue", "purple", "brown"]
    
    // 캘린더 객체 추가
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            Form {
                // 섹션 1: 일정 정보
                Section(header: Text("일정 정보")) {
                    HStack {
                        Text("그룹")
                        Spacer()
                        Text(groupName)
                            .foregroundColor(.gray)
                    }
                    
                    TextField("제목", text: $title)
                    
                    TextField("내용", text: $content)
                        .frame(height: 100)
                }
                
                // 섹션 2: 시간 설정
                Section(header: Text("시간 설정")) {
                    Toggle("시간 고정", isOn: $isTimeFixed)
                    
                    if isTimeFixed {
                        Toggle("종일", isOn: $isAllDay)
                        
                        DatePicker("시작 시간", selection: $startTime, displayedComponents: .hourAndMinute)
                            .disabled(isAllDay)
                        
                        DatePicker("종료 시간", selection: $endTime, displayedComponents: .hourAndMinute)
                            .disabled(isAllDay)
                    }
                }
                
                // 섹션 3: 날짜 선택
                Section(header: Text("날짜 선택")) {
                    HStack {
                        Text("선택된 날짜: \(selectedDates.count)개")
                        Spacer()
                        Button("날짜 선택") {
                            showingDatePicker = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    ForEach(scheduleDateItems.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("후보 \(index + 1)")
                                .font(.headline)
                            
                            Text(formatDate(scheduleDateItems[index].date))
                                .foregroundColor(.gray)
                            
                            if !isTimeFixed {
                                Toggle("종일", isOn: $scheduleDateItems[index].isAllDay)
                                
                                if !scheduleDateItems[index].isAllDay {
                                    DatePicker("시작 시간",
                                        selection: $scheduleDateItems[index].startTime,
                                        displayedComponents: .hourAndMinute)
                                    
                                    DatePicker("종료 시간",
                                        selection: $scheduleDateItems[index].endTime,
                                        displayedComponents: .hourAndMinute)
                                }
                            } else {
                                if isAllDay {
                                    Text("종일")
                                        .foregroundColor(.gray)
                                } else {
                                    HStack {
                                        Text("시작: ")
                                        Text(formatTime(startTime))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    HStack {
                                        Text("종료: ")
                                        Text(formatTime(endTime))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.vertical, 4)
                    }
                }
                    
                // 섹션 4: 색상 선택
                Section(header: Text("색상 선택")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(colorMap[color, default: .blue])
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedColor == color ? Color.black : Color.clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
                
                // 섹션 5: 제안 버튼
                Section {
                    Button(action: proposeSchedule) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("일정 제안하기")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isFormValid ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!isFormValid || isLoading)
                }
            }
            .navigationTitle("그룹 일정 제안")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                // 그룹 멤버 목록 가져오기
                groupViewModel.fetchGroupMembers(groupID: groupID)
                
                // 그룹 이름 가져오기
                fetchGroupName()
            }
            .onChange(of: selectedDates) {
                updateScheduleDateItems()
            }
            .onChange(of: isTimeFixed) {
                if isTimeFixed {
                    updateScheduleDateItems()
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                DateSelectionView(selectedDates: $selectedDates)
            }
            
        }
    }
    
    // MARK: - Methods
    
    // 폼 유효성 검사
    private var isFormValid: Bool {
        !title.isEmpty &&
        !content.isEmpty &&
        (!isTimeFixed || startTime <= endTime) &&
        !selectedDates.isEmpty
    }
    
    // 그룹 이름 가져오기
    func fetchGroupName() {
        groupViewModel.fsDB.collection("groups").document(groupID).getDocument { snapshot, error in
            if let document = snapshot, document.exists,
               let data = document.data(),
               let name = data["groupName"] as? String {
                DispatchQueue.main.async {
                    self.groupName = name
                }
            }
        }
    }

    // 날짜 형식 지정
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

    // 시간 형식 지정
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // 일정 제안 기능 - scheduleDateItems 사용하도록 수정
    private func proposeSchedule() {
        isLoading = true
        
        // scheduleDateItems를 사용하여 일정 생성
        var schedule: [TimeSlotGroup] = []
        
        for item in scheduleDateItems {
            schedule.append(
                TimeSlotGroup(
                    startTime: item.startTime,
                    endTime: item.endTime,
                    isAllDay: item.isAllDay
                )
            )
        }
        
        scheduleViewModel.proposeGroupSchedule(
            groupID: groupID,
            title: title,
            content: content,
            creator: userID,
            schedule: schedule,
            groupColor: selectedColor,
            members: groupViewModel.getGroupMembers(groupID: groupID)
        ) { success in
            isLoading = false
            
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    // selectedDates가 변경될 때 scheduleDateItems 업데이트
    private func updateScheduleDateItems() {
        // 기존 항목 유지
        let existingItems = Dictionary(grouping: scheduleDateItems, by: { calendar.startOfDay(for: $0.date) })
        
        // 새로운 항목 배열 생성
        var newItems: [ScheduleDateItem] = []
        
        for date in selectedDates {
            let startOfDay = calendar.startOfDay(for: date)
            
            if let existingItem = existingItems[startOfDay]?.first {
                // 기존 항목 유지
                newItems.append(existingItem)
            } else {
                // 새 항목 추가
                if isTimeFixed {
                    // 고정 시간 사용
                    var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
                    let timeComponents = calendar.dateComponents([.hour, .minute], from: startTime)
                    startComponents.hour = timeComponents.hour
                    startComponents.minute = timeComponents.minute
                    
                    var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
                    let endTimeComponents = calendar.dateComponents([.hour, .minute], from: endTime)
                    endComponents.hour = endTimeComponents.hour
                    endComponents.minute = endTimeComponents.minute
                    
                    let itemStartTime = calendar.date(from: startComponents) ?? date
                    let itemEndTime = calendar.date(from: endComponents) ?? date
                    
                    newItems.append(ScheduleDateItem(
                        date: date,
                        isAllDay: isAllDay,
                        startTime: itemStartTime,
                        endTime: itemEndTime
                    ))
                } else {
                    // 기본값: 종일
                    newItems.append(ScheduleDateItem(
                        date: date,
                        isAllDay: true,
                        startTime: startOfDay,
                        endTime: calendar.date(byAdding: .day, value: 1, to: startOfDay)?.addingTimeInterval(-1) ?? date
                    ))
                }
            }
        }
        
        scheduleDateItems = newItems
    }
}

#Preview {
    ProposeGroupScheduleView(userID: "user123", groupID: "group123")
}
