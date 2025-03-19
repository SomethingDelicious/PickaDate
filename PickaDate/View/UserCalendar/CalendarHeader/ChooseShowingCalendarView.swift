//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI
import FirebaseFirestore

struct ChooseShowingCalendarView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var userViewModel: UserViewModel
    
    let user: PDUser?
    
    @Binding var selectedCalendars: Set<String>
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    Toggle("개인 캘린더", isOn: Binding(
                        get: { selectedCalendars.contains("개인 캘린더") },
                        set: { isSelected in
                            if isSelected {
                                selectedCalendars.insert("개인 캘린더")
                            } else {
                                selectedCalendars.remove("개인 캘린더")
                            }
                        }
                    ))
                    .padding(.horizontal)

                    ForEach(user?.joinedGroups ?? [], id: \.self) { group in
                        Toggle(group, isOn: Binding(
                            get: { selectedCalendars.contains(group) },
                            set: { isSelected in
                                if isSelected {
                                    selectedCalendars.insert(group)
                                } else {
                                    selectedCalendars.remove(group)
                                }
                            }
                        ))
                        .padding(.horizontal)
                    }
                    Spacer()
                }
            }
            

            .padding()
            .navigationBarItems(
                leading: Button("닫기") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("저장") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            
            
            .onAppear {
                userViewModel.fetchUserSchedules()
            }
        }
        .navigationTitle(Text("일정 공유 그룹"))
        .navigationBarTitleDisplayMode(.inline)
        
        
    }
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
}
