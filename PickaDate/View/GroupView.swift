//
//  GroupView.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/18/25.
//

import SwiftUI

struct GroupView: View {
    @EnvironmentObject private var groupViewModel: GroupViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // 현재 선택된 그룹 정보 표시
                if let currentGroup = groupViewModel.currentGroup {
                    GroupHeaderView(group: currentGroup)
                        .padding()
                } else {
                    Text("선택된 그룹이 없습니다.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
                
                // 그룹 관련 메뉴
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
                    NavigationLink(destination: GroupScheduleView()) {
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
            } // VStack1
            .navigationTitle("그룹")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                groupViewModel.fetchUserGroups()
            }
            
        }
    }
}

// 현재 선택된 그룹 정보를 표시하는 헤더 뷰
struct GroupHeaderView: View {
    let group: PDGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.groupName)
                .font(.title)
                .fontWeight(.bold)
            
            Text("리더: \(group.leader)")
                .font(.subheadline)
            
            Text("멤버: \(group.members.count)명")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // 생성 날짜
            Text("생성일: \(formattedDate(group.createdAt))")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
    
    // 날짜 형식 변환 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
}

#Preview {
    GroupView()
}
