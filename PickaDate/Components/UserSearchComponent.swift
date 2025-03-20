//
//  UserSearchComponent.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI
import FirebaseFirestore

// 선택된 멤버 정보를 저장할 구조체 추가
struct SelectedMember {
    var userName: String
    var userID: String
}

struct UserSearchComponent: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @Binding var selectedMembers: [SelectedMember] // 선택된 멤버 목록
    
    @State private var searchText = ""
    @State private var searchResults: [PDUser] = []
    @State private var isSearching = false
    
    private let fsDB = Firestore.firestore()
    
    var body: some View {
        VStack {
            // 검색 바
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("사용자 이름으로 검색", text: $searchText)
                    .autocapitalization(.none)
                    .onChange(of: searchText) {
                        if !searchText.isEmpty {
                            searchUsers(userName: searchText)
                        } else {
                            searchResults = []
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // 검색 결과 또는 로딩 표시
            if isSearching {
                ProgressView()
                    .padding()
                Spacer()
            } else if searchResults.isEmpty && !searchText.isEmpty {
                Text("검색 결과가 없습니다.")
                    .foregroundColor(.gray)
                    .padding()
                Spacer()
            } else {
                // 검색 결과 목록
                List {
                    ForEach(searchResults, id: \.userID) { user in
                        HStack {
                            Text(user.userName)
                                .font(.headline)
                            
                            Spacer()
                            
                            // 이미 선택된 멤버인지 확인
                            if selectedMembers.contains(where: { $0.userID == user.userID }) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            } else {
                                Button(action: {
                                    // userID와 userName 모두 저장
                                    let newMember = SelectedMember(
                                        userName: user.userName,
                                        userID: user.userID
                                    )
                                    // 멤버 추가
                                    selectedMembers.append(newMember)
                                    
                                    // 선택 후 창 닫기
                                    dismiss()
                                }) {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("사용자 검색")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    dismiss()
                }
            }
        }
    }
    
    // 사용자 검색 함수
    // TODO: 뷰모델로 옮기기
    private func searchUsers(userName: String) {
        isSearching = true
        
        fsDB.collection("users")
            .whereField("userName", isGreaterThanOrEqualTo: userName)
            .whereField("userName", isLessThanOrEqualTo: userName + "\u{f8ff}")
            .limit(to: 20) // 검색 결과 제한
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E] 사용자 검색 실패: \(error.localizedDescription)")
                    isSearching = false
                    return
                }
                
                DispatchQueue.main.async {
                    // 검색 결과에서 현재 사용자만 제외
                    searchResults = snapshot?.documents.compactMap { doc -> PDUser? in
                        if let user = try? doc.data(as: PDUser.self) {
                            // 현재 로그인한 사용자만 제외
                            if user.userID == userViewModel.currentUser?.userID {
                                return nil
                            }
                            return user
                        }
                        return nil
                    } ?? []
                    
                    isSearching = false
                    print("[L] 사용자 검색 성공: \(searchResults.count)명")
                }
            }
    }
}

