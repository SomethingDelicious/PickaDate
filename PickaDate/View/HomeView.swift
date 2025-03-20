//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var groupViewModel: GroupViewModel
    @State private var selectedTab = 0
    @State private var isShowingUserScheduleView = false
    @State private var isShowingGroupScheduleView = false
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                MainView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("홈")
                    }
                    .tag(0)
                
                UserCalendarView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("개인")
                    }
                    .tag(1)
                
                Text("")
                    .tabItem {
                        Text("")
                    }
                    .tag(2)
                
                GroupView()
                    .tabItem {
                        Image(systemName: "person.3.sequence.fill")
                        Text("그룹")
                    }
                    .tag(3)
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("설정")
                    }
                    .tag(4)
            }
            .tint(Color.pointColor)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if selectedTab == 1 {
                            print("개인 일정 추가 화면")
                            isShowingUserScheduleView = true
                        } else if selectedTab == 3 {
                            print("그룹 일정 추가 화면")
                            isShowingGroupScheduleView = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color.pointColor)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    //.offset(y: -30)
                    .sheet(isPresented: $isShowingUserScheduleView, onDismiss: {
                        userViewModel.fetchUserSchedules()
                    }) {
                        AddUserScheduleView(selectedDate: Date())
                    }
                    .sheet(isPresented: $isShowingGroupScheduleView) {
                        ProposeGroupScheduleView(userID: userViewModel.currentUser?.userID ?? "", groupID: groupViewModel.currentGroup?.groupID ?? "")
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 10)
        } // ZStack
        .onAppear {
            Task {
                if userViewModel.currentUser == nil {
                    do {
                        print("HomeView: 사용자 정보 가져오기 시도")
                        try await userViewModel.fetchCurrentUser()
                    } catch {
                        print("[E] HomeView에서 사용자 정보 가져오기 실패: \(error.localizedDescription)")
                    }
                } else {
                    print("HomeView: 이미 사용자 정보 있음")
                    userViewModel.fetchUserSchedules()
                }
            }
        }
    }
}
