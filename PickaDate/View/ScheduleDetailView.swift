//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct ScheduleDetailView: View {
    let schedule: PersonalSchedule
    let user: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                Text(schedule.name)
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(schedule.color)
                if let firstSchedule = schedule.schedule.first {
                    Text("\(formattedDate(firstSchedule.startTime)) ~ \(formattedDate(firstSchedule.endTime))")
                        .font(.body)
                        .foregroundColor(.black)
                }
                
            }
            .padding()
            Divider()
            VStack(alignment: .leading, spacing: 10) {
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
                    Text(user)
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
                    Text("그룹: \(schedule.groupID.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                
                
                
                
                
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            print("편집 선택됨")
                        }) {
                            Label("편집", systemImage: "pencil")
                        }

                        Button(action: {
                            print("복사 선택됨")
                        }) {
                            Label("복사", systemImage: "doc.on.doc")
                        }

                        Button(action: {
                            print("여러 날짜에 복사 선택됨")
                        }) {
                            Label("여러 날짜에 복사", systemImage: "calendar.badge.plus")
                        }

                        Button(role: .destructive, action: {
                            print("삭제 선택됨")
                        }) {
                            Label("삭제", systemImage: "trash")
                        }

                        Button(action: {
                            print("공유 선택됨")
                        }) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.black)
                    }
                }
            }

        }
        
    }
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 E요일"
        return formatter.string(from: date)
    }
}
