//
//  ContentView.swift
//  PickaDate
//
//  Created by 김태건 on 2/20/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = FirestoreViewModel()

    var body: some View {
        TabView{
            MainView()
                .tabItem {
                    Image(systemName: "house")
                    Text("홈")
                }
 
            PersonalScheduleView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("개인")
                }
    
            GroupDateView()
                .tabItem {
                    Image(systemName: "person.3.sequence.fill")
                    Text("그룹")
                }
        }

        //        NavigationView {
        //            VStack {
        //                List(viewModel.userTestData) { userTestData in
        //                    HStack {
        //                        VStack(alignment: .leading) {
        //                            Text(userTestData.text).font(.headline)
        //                            Text("숫자: \(userTestData.num)").font(.subheadline)
        //                        }
        //                        Spacer()
        //                        Button(action: {
        //                            if let userId = userTestData.id {
        //                                viewModel.deleteUser(userId: userId)
        //                            }
        //                        }) {
        //                            Image(systemName: "trash")
        //                                .foregroundColor(.red)
        //                        }
        //                    }
        //
        //                }
        //                NavigationLink(destination: PersonalScheduleView()) {
        //                    Text("개인 일정 보기")
        //                        .font(.headline)
        //                        .padding()
        //                        .frame(maxWidth: .infinity)
        //                        .background(Color.blue)
        //                        .foregroundColor(.white)
        //                        .cornerRadius(10)
        //                }
        //                .padding()
        //                Button("데이터 추가") {
        //                    viewModel.addUser(text: "텍스트", num: 26)
        //                }
        //                .padding()
        //            }
        //            .navigationTitle("데이터 목록")
        //            .onAppear {
        //                viewModel.fetchUsers()
        //            }
        //        }
    }
}


