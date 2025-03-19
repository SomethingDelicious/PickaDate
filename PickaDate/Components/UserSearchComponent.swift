//
//  UserSearchComponent.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/19/25.
//

import SwiftUI
import FirebaseFirestore

struct UserSearchComponent: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedMembers: [String] // 선택된 멤버 목록
    
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
                    .onChange(of: searchText) { newValue in
                        if !newValue.isEmpty {
                            searchUsers(userName: newValue)
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
                            if selectedMembers.contains(user.userName) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            } else {
                                Button(action: {
                                    // 멤버 추가
                                    selectedMembers.append(user.userName)
                                    
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
    private func searchUsers(userName: String) {
        isSearching = true
        
        fsDB.collection("users")
            .whereField("userName", isGreaterThanOrEqualTo: userName)
            .whereField("userName", isLessThanOrEqualTo: userName + "\u{f8ff}")
            .limit(to: 10) // 검색 결과 제한
            .getDocuments { snapshot, error in
                if let error = error {
                    print("[E] 사용자 검색 실패: \(error.localizedDescription)")
                    isSearching = false
                    return
                }
                
                DispatchQueue.main.async {
                    searchResults = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: PDUser.self)
                    } ?? []
                    isSearching = false
                    print("[L] 사용자 검색 성공: \(searchResults.count)명")
                }
            }
    }
}

//#Preview {
//    UserSearchComponent()
//}
