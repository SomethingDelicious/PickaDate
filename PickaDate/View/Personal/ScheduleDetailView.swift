//
//  ScheduleDetailView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI
import FirebaseFirestore




struct ScheduleDetailView: View {
    let schedule: PersonalSchedule
    let user: User
    @Environment(\.presentationMode) var presentationMode
    @State private var isEditing = false
    @State private var isCopying = false
    @State private var isSharing = false
    @StateObject private var viewModel = FirestoreViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(alignment: .center) {
                    Text(schedule.name)
                        .font(.largeTitle)
                        .bold()
                        .foregroundColor(schedule.color)
                    if let firstSchedule = schedule.schedule.first {
                        if (firstSchedule.startTime == firstSchedule.endTime) {
                            Text("\(formattedDate(firstSchedule.startTime))")
                                .font(.body)
                                .foregroundColor(.black)
                        } else {
                            Text("\(formattedDate(firstSchedule.startTime)) ~ \(formattedDate(firstSchedule.endTime))")
                                .font(.body)
                                .foregroundColor(.black)
                        }
                        
                    }
                    
                }
                .padding()
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.body)
                            .foregroundColor(schedule.color)
                        if let firstSchedule = schedule.schedule.first {
                            if firstSchedule.isAllDay {
                                Text("종일")
                                    .font(.body)
                                    .foregroundColor(.black)
                            } else {
                                if Calendar.current.isDate(firstSchedule.startTime, inSameDayAs: firstSchedule.endTime) {
                                    Text("\(formattedTime(firstSchedule.startTime)) ~ \(formattedTime(firstSchedule.endTime))")
                                        .font(.body)
                                        .foregroundColor(.black)
                                } else {
                                    Text("\(formattedDateTime(firstSchedule.startTime)) ~ \(formattedDateTime(firstSchedule.endTime))")
                                        .font(.body)
                                        .foregroundColor(.black)
                                }
                            }
                        } else {
                            Text("일정 없음")
                                .font(.body)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    HStack {
                        Image(systemName: "document")
                            .font(.body)
                            .foregroundColor(schedule.color)
                        Text(schedule.content)
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    HStack {
                        Image(systemName: "calendar")
                            .font(.body)
                            .foregroundColor(schedule.color)
                        Text(user.userID)
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    HStack {
                        Image(systemName: "paintpalette")
                            .font(.body)
                            .foregroundColor(schedule.color)
                        Text(schedule.personalColor)
                            .font(.body)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding()
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.body)
                            .foregroundColor(schedule.color)
                        Text(schedule.groupID.isEmpty ? "없음" : schedule.groupID.joined(separator: ", "))
                            .font(.body)
                            .foregroundColor(.black)

                        
                        Spacer()
                    }
                    .padding()
                    
                    
                    
                    
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                
            }
            .onAppear {
                viewModel.fetchPersonalSchedules()
            }
            
        }
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    
                    Button(action: {
                        print("편집 선택됨")
                        isEditing.toggle()
                    }) {
                        Label("편집", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        print("여러 날짜에 복사 선택됨")
                        isCopying.toggle()
                    }) {
                        Label("여러 날짜에 복사", systemImage: "calendar.badge.plus")
                    }
                    
                    
                    Button(action: {
                        print("공유 선택됨")
                        isSharing.toggle()
                    }) {
                        Label("공유", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive, action: {
                        guard let scheduleID = schedule.id else {
                            print("schedule.id가 nil")
                            return
                        }
                        viewModel.deletePersonalSchedule(scheduleID: scheduleID)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.black)
                }
            }
            
        }
        .sheet(isPresented: $isEditing, onDismiss: {
            viewModel.fetchPersonalSchedules()
        }) {
            EditPersonalScheduleView(user: user, schedule: schedule)
        }
        .sheet(isPresented: $isCopying, onDismiss: {
            viewModel.fetchPersonalSchedules()
        }) {
            CopyPersonalScheduleView(user: user, schedule: schedule)
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $isSharing, onDismiss: {
            viewModel.fetchPersonalSchedules()
        }) {
            SharePersonalScheduleView(user: user, schedule: schedule)
                .environmentObject(viewModel)
        }
        
        
        
    }
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 E요일"
        return formatter.string(from: date)
    }
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 (E) HH:mm"
        return formatter.string(from: date)
    }
    
}
