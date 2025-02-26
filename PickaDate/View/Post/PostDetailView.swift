//
//  PostDetailView.swift
//  PickaDate
//
//  Created by mwpark on 2/23/25.
//

import SwiftUI

struct PostDetailView: View {
    @State private var postID: String
    @State private var commentID: String = ""
    @StateObject private var viewModel = PostViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var newCommentText = ""
    @State private var showingCommentForm = false
    @State private var showingDeletePostAlert: Bool = false
    @State private var showingEditPostAlert: Bool = false
    @State private var showingDeleteCommentAlert: Bool = false
    
    // 댓글
    @State private var isAnonymous: Bool = false
    @StateObject private var groupViewModel = GroupViewModel()
    @State private var commentContent = ""
    @State private var commentWriter = "멋사"
    
    init(post: Post) {
        self.postID = post.postID
    }
    
    // 현재 post를 계산 프로퍼티로 구현
    private var post: Post {
        viewModel.posts.first { $0.postID == postID } ?? Post(postID: "", groupID: "", title: "", content: "", writer: "", createdAt: Date())
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
                        Text("댓글 \(viewModel.comments[postID]?.count ?? 0)개")
                            .font(.headline)
                        
                        Spacer()
//                        // 미관상 없애는 것이 좋아서 주석처리함.
//                        Button(action: {
//                            showingCommentForm = true
//                        }) {
//                            Text("댓글 작성")
//                                .font(.subheadline)
//                                .foregroundColor(.blue)
//                        }
                    }
                    
                    if (viewModel.comments[postID]?.count ?? 0) == 0 {
                        Text("아직 댓글이 없습니다.")
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.comments[postID]?.sorted(by: { $0.createdAt < $1.createdAt }) ?? [], id: \.id) { comment in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(comment.writer)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                    
                                    Text(formatDate(comment.createdAt))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Menu {
                                        Button(role: .destructive, action: {
                                            showingDeleteCommentAlert = true
                                            commentID = comment.commentID
                                        }) {
                                            Label("삭제", systemImage: "trash")
                                        }
                                    } label: {
                                        Image(systemName: "ellipsis")
                                            .rotationEffect(.degrees(90))
                                            .font(.caption)
                                            .foregroundColor(.black)
                                            .padding(.leading, 4)
                                    }
                                    
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
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(post.title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.backward")
                    }
                    .foregroundColor(.blue)
                }
            }
            
            ToolbarItem(placement: .primaryAction) {
                Menu(content: {
                    Button(action: {
                        showingEditPostAlert = true
                    }) {
                        HStack {
                            Text("수정")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                    }
                    
                    Button(action: {
                        showingDeletePostAlert = true
                    }) {
                        HStack {
                            Text("삭제")
                            Spacer()
                            Image(systemName: "trash")
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
        .sheet(isPresented: $showingCommentForm, onDismiss: {
            viewModel.fetchPosts()
        }) {
            AddCommentView(post: post)
        }
        .sheet(isPresented: $showingEditPostAlert, onDismiss: {
            viewModel.fetchPosts()
        }) {
            EditPostView(post: post)
        }
        .alert("이 게시물을 삭제하시겠습니까?", isPresented: $showingDeletePostAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                viewModel.deletePost(postID: postID)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .alert("이 댓글을 삭제하시겠습니까?", isPresented: $showingDeleteCommentAlert) {
            Button("취소", role: .cancel) { }
            Button("확인", role: .destructive) {
                viewModel.deleteComment(postID: postID, commentID: commentID)
            }
        }
        
        // 댓글 입력 창
        HStack {
            Button(action: {
                isAnonymous.toggle()
                if isAnonymous {
                    commentWriter = "익명"
                } else {
                    commentWriter = "익명"
                }
                
            }, label: {
                HStack {
                    Image(systemName: isAnonymous ? "checkmark.square" : "square")
                    Text("익명")
                }
                .foregroundStyle(isAnonymous ? .red : .gray)
            })
            
            TextField("댓글을 입력하세요.", text: $commentContent)
            
            Button(action: {
                if(!commentContent.isEmpty && !commentWriter.isEmpty) {
                    viewModel.addComment(postID: postID, content: commentContent, writer: commentWriter)
                    isAnonymous = false
                    commentWriter = "멋사"
                    commentContent = ""
                }
                viewModel.fetchPosts()
            }, label: {
                Image(systemName: "paperplane")
                    .foregroundStyle(.red)
            })
            .disabled(commentContent.isEmpty || commentWriter.isEmpty)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(10)
        .frame(height: 40)
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
