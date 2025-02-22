//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct PersonalDateScheduleView: View {
    @StateObject private var viewModel = FirestoreViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingAddSchedule = false

    
    var selectedDate: Int
    var year: Int
    var month: Int
    let schedules: [PersonalSchedule]
    let user: String
    
    var body: some View {
        NavigationView {
            VStack {
                if schedules.isEmpty {
                                Text("일정이 없습니다.")
                                    .foregroundColor(.gray)
                            } else {
                                List(schedules, id: \.id) { schedule in
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(schedule.name)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        
                                        Text(schedule.content)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        Text("그룹: \(schedule.groupID.joined(separator: ", "))")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(schedule.color)
                                    .cornerRadius(10)
                                }
                            }
                
                Spacer()
            }
            .navigationTitle(Text(formattedDate(createDate(year: year, month: month, day: selectedDate))))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                    .foregroundColor(.black)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isShowingAddSchedule.toggle()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.black)
                    }
                    .sheet(isPresented: $isShowingAddSchedule) {
                        let selectedDateObject = createDate(year: year, month: month, day: selectedDate)
                        AddPersonalScheduleView(user: user, selectedDate: selectedDateObject)
                    }

                }
            }
            .background(Color.black.ignoresSafeArea())
        }
    }
    private func createDate(year: Int, month: Int, day: Int) -> Date {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = day
            return Calendar.current.date(from: components) ?? Date()
        }
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 E요일"
        return formatter.string(from: date)
    }
    func isDateInRange(date: Int, startDate: Date, endDate: Date, year: Int, month: Int) -> Bool {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startDate)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: endDate)
        
        return (startComponents.year == year && startComponents.month == month && startComponents.day! <= date) &&
               (endComponents.year == year && endComponents.month == month && endComponents.day! >= date)
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
