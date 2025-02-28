//
//  PostView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
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
            .onAppear {
                viewModel.fetchPosts()
            }
            .refreshable {
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
