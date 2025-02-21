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
        NavigationView {
            VStack {
                List(viewModel.userTestData) { userTestData in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(userTestData.text).font(.headline)
                            Text("숫자: \(userTestData.num)").font(.subheadline)
                        }
                        Spacer()
                        Button(action: {
                            if let userId = userTestData.id {
                                viewModel.deleteUser(userId: userId)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Button("데이터 추가") {
                    viewModel.addUser(text: "텍스트", num: 25)
                }
                .padding()
            }
            .navigationTitle("데이터 목록")
            .onAppear {
                viewModel.fetchUsers()
            }
        }
    }
}


