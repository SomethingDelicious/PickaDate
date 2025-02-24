//
//  PostView.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI

struct PostView: View {
    @StateObject private var viewModel = PostViewModel()
    @State private var showingAddPost: Bool = false
    @State private var groupID: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var writer: String = ""
    
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
                ForEach(viewModel.posts.sorted(by: { $0.createdAt < $1.createdAt })) { postData in
                    NavigationLink(destination: PostDetailView(post: postData)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(postData.title)
                                .font(.headline)
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
                    Text("게시판")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                    }, label: {
                        Image(systemName: "magnifyingglass")
                    })
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu(content: {
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
