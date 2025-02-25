//
//  PostView.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @StateObject private var groupViewModel = GroupViewModel()
    @State private var showingAddPost: Bool = false
    @State private var groupID: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var writer: String = ""
    
    // groupID로 바꿀 예정
    @State private var selectedGroupName: String = ""
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.posts.isEmpty {
                    Text("텅...")
                        .font(.title)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
                ForEach(viewModel.posts.filter { post in
                    if post.groupID == selectedGroupName {
                        return true
                    } else if selectedGroupName == "" {
                        return true
                    } else {
                        return false
                    }
                }
                    .sorted(by: { $0.createdAt < $1.createdAt })) { postData in
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
                                
                                Text("댓글 \(viewModel.comments[postData.postID]?.count ?? 0)개")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 4)
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
                            }) {
                                HStack {
                                    Text("전체그룹")
                                    Spacer()
                                    Image(systemName: selectedGroupName == "" ? "checkmark.square.fill" : "")
                                }
                            }
                            ForEach(groupViewModel.groups) { group in
                                Button(action: {
                                    selectedGroupName = group.groupName
                                }) {
                                    HStack {
                                        Text(group.groupName)
                                        Spacer()
                                        Image(systemName: selectedGroupName == group.groupName ? "checkmark.square.fill" : "")
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
                viewModel.fetchPosts()
                groupViewModel.fetchGroups()
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
