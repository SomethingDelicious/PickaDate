//
//  GroupView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/18/25.
//

import SwiftUI

struct GroupView: View {
    var body: some View {
        NavigationView {
            List {
                // 그룹 검색
                NavigationLink(destination: GroupListView()) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.blue)
                        Text("그룹 검색")
                    }
                }
                
                // 그룹 추가
                NavigationLink(destination: GroupAddView()) {
                    HStack {
                        Image(systemName: "plus.circle")
                            .foregroundStyle(.blue)
                        Text("그룹 추가")
                    }
                }
                
                // 그룹 캘린더
                NavigationLink(destination: GroupCalendarView()) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.blue)
                        Text("그룹 캘린더")
                    }
                }
                
                // 그룹 게시판
                NavigationLink(destination: PostView()) {
                    HStack {
                        Image(systemName: "list.clipboard")
                            .foregroundStyle(.blue)
                        Text("그룹 게시판")
                    }
                }
            }
        }
    }
}

#Preview {
    GroupView()
}
