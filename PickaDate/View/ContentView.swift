//
//  ContentView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//


import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FirestoreViewModel()
    @State private var selectedTab = 0
    
    //더미데이터
   let user = User.init(userID: "1234", userName: "기본이름", email: "abc1234@google.com", userPW: "password")
    let groupName = "맛있는거사조"
    let userId: String = "jiyong7578"
    let groupId: String = "group1"
    
    @State private var isShowingPersonalScheduleView = false
    // @State private var isShowingGroupScheduleView = false
    @State private var isShowingProposeGroupScheduleView = false
    
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
                
                GroupScheduleView()
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
                            isShowingProposeGroupScheduleView = true
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
                    .sheet(isPresented: $isShowingProposeGroupScheduleView) {
                        ProposeGroupScheduleView(userID: userId, groupID: groupId)
                    }
                    Spacer()
                }
            }
            .padding(.bottom, 10)
        }
    }
}

