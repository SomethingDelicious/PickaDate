//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct UserDateScheduleView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var isShowingAddSchedule = false
    
    
    var selectedDate: Date
    var userSchedules: [PDUserSchedule]
    
    var body: some View {
        NavigationView {
            VStack {
                if userSchedules.isEmpty {
                    Text("일정이 없습니다.")
                        .foregroundColor(.gray)
                } else {
                    List(userSchedules, id: \.id) { schedule in
                        NavigationLink(destination: ScheduleDetailView(schedule: schedule)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(schedule.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(schedule.content)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Text("그룹: \(schedule.groupIDs.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(schedule.color)
                            .cornerRadius(10)
                        }
                        
                    }
                }
                
                Spacer()
            }
            .navigationTitle(Text(formattedDate(selectedDate)))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        presentationMode.wrappedValue.dismiss()
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
                    .sheet(isPresented: $isShowingAddSchedule, onDismiss: {
                        userViewModel.fetchUserSchedules()
                    }) {
                        AddUserScheduleView(selectedDate: selectedDate)
                    }
                    
                }
            }
            .onAppear {
                userViewModel.fetchUserSchedules()
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
