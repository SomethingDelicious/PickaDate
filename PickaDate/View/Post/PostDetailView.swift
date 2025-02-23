//
//  PostDetailView.swift
//  PickaDate
//
//  Created by mwpark on 2/23/25.
//

import SwiftUI

struct PostDetailView: View {
    @State private var post: Post
    @StateObject private var viewModel = PostViewModel()
    @State private var commentsCount: Int
    @State private var newCommentText = ""
    @State private var showingCommentForm = false
    
    init(post: Post, commentsCount: Int) {
        self.post = post
        self.commentsCount = commentsCount
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 게시물 내용
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(post.writer)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        Text(formatDate(post.createdAt))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(post.content)
                        .padding(.vertical, 8)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                
                // 댓글 갯수
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("댓글 \(commentsCount)개")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingCommentForm = true
                        }) {
                            Text("댓글 작성")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }

                    if commentsCount == 0 {
                        Text("아직 댓글이 없습니다.")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.comments[post.postID]?.sorted(by: { $0.createdAt < $1.createdAt }) ?? [], id: \.id) { comment in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(comment.writer)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Text(formatDate(comment.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Text(comment.content)
                                    .padding(.top, 2)
                            }
                            .padding()
                            .background(.gray)
                            .opacity(0.5)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle(post.title)
        .onAppear {
            // 주석을 지우자.
            viewModel.fetchPosts()
        }
        .sheet(isPresented: $showingCommentForm) {
            AddCommentView(post: post)
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
