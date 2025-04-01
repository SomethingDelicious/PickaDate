//
//  PostView.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    //    @StateObject private var groupViewModel = GroupViewModel()
    @StateObject private var userViewModel = UserViewModel()
    
    @State private var showingAddPost: Bool = false
    @State private var groupID: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var writer: String = ""
    
    @State private var selectedGroupID: String = ""
    @State private var selectedGroupName: String = ""
    
    
    var body: some View {
        NavigationView {
            List {
                // 이전에 전체 게시물이 없는 경우에만 텅...이 표시되도록 하였음
                // 그룹마다 필터링해서 필터링한 글이 없는 경우 텅...이 표시되도록 변경하였음
                let filteredPosts = viewModel.posts
                    .filter { $0.groupID == selectedGroupID }
                    .sorted { $0.createdAt < $1.createdAt }
                
                if filteredPosts.isEmpty {
                    Text("텅...")
                        .font(.title)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(filteredPosts) { postData in
                        NavigationLink(destination: PostDetailView(post: postData)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(postData.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                HStack {
                                    Text(postData.writer)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(formatDate(postData.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                HStack {
                                    HStack {
                                        Image(systemName: "heart")
                                        Text("\(postData.likes)")
                                            .font(.caption)
                                    }
                                    .foregroundStyle(.red)
                                    HStack {
                                        Image(systemName: "message")
                                        Text("\(viewModel.comments[postData.postID]?.count ?? 0)")
                                            .font(.caption)
                                    }
                                    .foregroundColor(.blue)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("게시판")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("게시판")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        Text(selectedGroupName == "" ? "전체그룹" : "\(selectedGroupName)")
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu(content: {
                        // 게시판 변경 서브메뉴
                        Menu(content: {
                            Button(action: {
                                selectedGroupName = ""
                                selectedGroupID = ""
                            }) {
                                HStack {
                                    Text("전체그룹")
                                    Spacer()
                                    Image(systemName: selectedGroupName == "" ? "checkmark.square.fill" : "")
                                }
                            }
                            
                            if let currentUser = userViewModel.currentUser {
                                ForEach(currentUser.joinedGroups, id: \.self) { group in
                                    Button(action: {
                                        selectedGroupName = group
                                        if let index = currentUser.joinedGroups.firstIndex(of: group),
                                           index < currentUser.joinedGroupUIDs.count {
                                            selectedGroupID = currentUser.joinedGroupUIDs[index]
                                        }
                                    }) {
                                        HStack {
                                            Text(group)
                                            Spacer()
                                            Image(systemName: selectedGroupName == group ? "checkmark.square.fill" : "")
                                        }
                                    }
                                }
                            }
                        }, label: {
                            HStack {
                                Text("게시판 변경")
                                Spacer()
                                Image(systemName: "bell.fill")
                            }
                        })
                        
                        Button(action: {
                            showingAddPost.toggle()
                        }) {
                            HStack {
                                Text("글쓰기")
                                Spacer()
                                Image(systemName: "pencil")
                            }
                        }
                    }, label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                    })
                }
                
            }
            .onAppear {
                Task {
                    try await userViewModel.fetchCurrentUser()
                    viewModel.fetchPosts()
                    
                    // 현재 선택한 그룹의 게시판으로 바로 이동하기 위해 초기화
                    if let currentUser = userViewModel.currentUser {
                        selectedGroupID = currentUser.onGroup
                        if let index = currentUser.joinedGroupUIDs.firstIndex(of: currentUser.onGroup),
                           index < currentUser.joinedGroups.count {
                            selectedGroupName = currentUser.joinedGroups[index]
                        }
                    }
                }
            }
            .refreshable {
                viewModel.fetchPosts()
            }
            .sheet(isPresented: $showingAddPost, onDismiss: {
                viewModel.fetchPosts()
            }) {
                AddPostView()
            }
        }
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}

#Preview {
    PostView()
}
