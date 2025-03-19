//
//  DateSelectionView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI
 
 struct DateSelectionView: View {
     @Binding var selectedDates: [Date]
     @Environment(\.presentationMode) var presentationMode
     @State private var currentMonth: Date = Date()
     @State private var temporarySelectedDates: [Date] = []
 
     let calendar = Calendar.current
 
     var body: some View {
         NavigationView {
             VStack {
                 // 월 선택 헤더
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
 
                 // 요일 헤더
                 WeekdayHeaderView()
 
                 // 날짜 그리드
                 let days = getDaysInMonth(for: currentMonth)
                 LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                     ForEach(days, id: \.self) { date in
                         DayCell(
                             date: date,
                             isSelected: isDateSelected(date, in: temporarySelectedDates),
                             isCurrentMonth: isSameMonth(date, currentMonth)
                         )
                         .onTapGesture {
                             toggleDateSelection(date)
                         }
                     }
                 }
                 .padding()
 
                 // 선택된 날짜 목록
                 ScrollView {
                     VStack(alignment: .leading, spacing: 8) {
                         Text("선택된 날짜")
                             .font(.headline)
                             .padding(.horizontal)
 
                         ForEach(temporarySelectedDates.sorted(), id: \.self) { date in
                             HStack {
                                 Text(selectedDateFormatter.string(from: date))
                                 Spacer()
                                 Button(action: {
                                     temporarySelectedDates.removeAll(where: { calendar.isDate($0, inSameDayAs: date) })
                                 }) {
                                     Image(systemName: "xmark.circle.fill")
                                         .foregroundColor(.red)
                                 }
                             }
                             .padding(.horizontal)
                             .padding(.vertical, 4)
                         }
                     }
                     .frame(maxWidth: .infinity)
                 }
                 .frame(maxHeight: 200)
 
                 Spacer()
             }
             .onAppear {
                 temporarySelectedDates = selectedDates
             }
             .navigationBarItems(
                 leading: Button("취소") {
                     presentationMode.wrappedValue.dismiss()
                 },
                 trailing: Button("완료") {
                     selectedDates = temporarySelectedDates
                     presentationMode.wrappedValue.dismiss()
                 }
             )
             .navigationTitle("날짜 선택")
             .navigationBarTitleDisplayMode(.inline)
         }
     }
 
     // 날짜 셀 구현
     private struct DayCell: View {
         let date: Date
         let isSelected: Bool
         let isCurrentMonth: Bool
 
         var body: some View {
             VStack {
                 Text("\(Calendar.current.component(.day, from: date))")
                     .foregroundColor(isCurrentMonth ? (isSelected ? .white : .black) : .gray)
                     .frame(width: 36, height: 36)
                     .background(
                         isSelected ? AnyView(Circle().fill(Color.blue)) : AnyView(EmptyView())
                     )
             }
             .padding(4)
         }
     }
 
     // 요일 헤더 뷰
     private struct WeekdayHeaderView: View {
         private let weekDays = ["일", "월", "화", "수", "목", "금", "토"]
 
         var body: some View {
             HStack {
                 ForEach(weekDays, id: \.self) { day in
                     Text(day)
                         .font(.caption)
                         .foregroundColor(.gray)
                         .frame(maxWidth: .infinity)
                 }
             }
         }
     }
 
     // 날짜 포맷터
     private var dateFormatter: DateFormatter {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy년 M월"
         return formatter
     }
 
     private var selectedDateFormatter: DateFormatter {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy년 M월 d일 (E)"
         formatter.locale = Locale(identifier: "ko_KR")
         return formatter
     }
 
     // 월 변경 함수
     private func changeMonth(by value: Int) {
         if let newDate = calendar.date(byAdding: .month, value: value, to: currentMonth) {
             currentMonth = newDate
         }
     }
 
     // 날짜 선택 토글
     private func toggleDateSelection(_ date: Date) {
         let startOfDay = calendar.startOfDay(for: date)
 
         if let index = temporarySelectedDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: startOfDay) }) {
             temporarySelectedDates.remove(at: index)
         } else {
             temporarySelectedDates.append(startOfDay)
         }
     }
 
     // 날짜가 이미 선택되었는지 확인
     private func isDateSelected(_ date: Date, in dates: [Date]) -> Bool {
         return dates.contains(where: { calendar.isDate($0, inSameDayAs: date) })
     }
 
     // 같은 월인지 확인
     private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
         let calendar = Calendar.current
         return calendar.component(.month, from: date1) == calendar.component(.month, from: date2) &&
                calendar.component(.year, from: date1) == calendar.component(.year, from: date2)
     }
 
     // 월에 해당하는 날짜 가져오기
     private func getDaysInMonth(for date: Date) -> [Date] {
         let calendar = Calendar.current
 
         // 해당 월의 첫날과 마지막날 구하기
         guard let monthInterval = calendar.dateInterval(of: .month, for: date),
               let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
               let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
             return []
         }
 
         // 첫 주부터 마지막 주까지의 모든 날짜를 배열로 만들기
         var result: [Date] = []
         var currentDate = monthFirstWeek.start
 
         while currentDate < monthLastWeek.end {
             result.append(currentDate)
             guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
             currentDate = nextDate
         }
 
         return result
     }
 }
 
