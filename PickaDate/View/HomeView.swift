//
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = FirestoreViewModel()
    @State private var selectedTab = 0
    
    //더미데이터
    let user = PDUser.init(userID: "1234", userPW: "password", registeredAt: Date(), joinGroup: ["group1", "group2"])
    let groupName = "맛있는거사조"
    
    @State private var isShowingPersonalScheduleView = false
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
                
                MainCalendarView(user: user)
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
                
                GroupDateView()
                    .tabItem {
                        Image(systemName: "person.3.sequence.fill")
                        Text("그룹")
                    }
                    .tag(3)
                
                PostView()
                    .tabItem {
                        Image(systemName: "bell.fill")
                        Text("게시판")
                    }
                    .tag(4)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if selectedTab == 1 {
                            print("개인 일정 추가 화면")
                            isShowingPersonalScheduleView = true
                        } else if selectedTab == 3 {
                            print("그룹 일정 추가 화면")
                            isShowingGroupScheduleView = true
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    //.offset(y: -30)
                    .sheet(isPresented: $isShowingPersonalScheduleView, onDismiss: {
                        viewModel.fetchPersonalSchedules()
                    }) {
                        AddPersonalScheduleView(user: user, selectedDate: Date())
                    }
                    .sheet(isPresented: $isShowingGroupScheduleView) {
                        AddGroupScheduleView(groupName: groupName)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 10)
        }
        
    }
}

