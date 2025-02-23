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
                ForEach(viewModel.posts.sorted(by: { $0.createdAt < $1.createdAt })) { postData in
                    NavigationLink(destination: PostDetailView(post: postData, commentsCount: viewModel.comments[postData.postID]?.count ?? 0)) {
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
            .onAppear {
                // 주석을 지우자.
                viewModel.fetchPosts()
            }
            .sheet(isPresented: $showingAddPost) {
                AddPostView()
            }
            .toolbar{
                ToolbarItem(placement: .confirmationAction) {
                    Button("새 게시판 추가") {
                        showingAddPost.toggle()
                    }
                }
            }
        }
        
        if viewModel.posts.isEmpty {
            Text("텅")
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

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostViewModel()
    @State private var title = ""
    @State private var content = ""
    @State private var writer = "익명"
    @State private var groupID = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                
                Section(header: Text("내용")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 200)
                }
                
                Section(header: Text("작성자")) {
                    TextField("작성자명", text: $writer)
                }
                
                Section(header: Text("작성자 그룹")) {
                    TextField("작성자 그룹을 입력하세요.", text: $groupID)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("등록") {
                        viewModel.addPost(groupID: groupID, title: title, content: content, writer: writer)
                        dismiss()
                    }
                    .disabled(title.isEmpty || writer.isEmpty || groupID.isEmpty)
                }
            }
        }
    }
}

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
                
                // 댓글 섹션
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
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// 댓글 작성 화면
struct AddCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostViewModel()
    
    @State private var post: Post
    
    @State private var content = ""
    @State private var writer = "익명"
    
    init(post: Post) {
        self.post = post
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("댓글 내용")) {
                    TextEditor(text: $content)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("작성자")) {
                    TextField("작성자명", text: $writer)
                }
            }
            .navigationTitle("댓글 작성")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("등록") {
                        viewModel.addComment(postID: post.postID, content: content, writer: writer)
                        dismiss()
                    }
                    .disabled(content.isEmpty || writer.isEmpty)
                }
            }
        }
    }
}
