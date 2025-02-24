//
//  EditPostView.swift
//  PickaDate
//
//  Created by mwpark on 2/24/25.
//

import SwiftUI

struct EditPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostViewModel()
    @State private var post: Post
    @State private var title: String
    @State private var content: String
    @State private var writer: String
    @State private var groupID: String
    
    init(post: Post) {
        self.post = post
        title = post.title
        content = post.content
        writer = post.writer
        groupID = post.groupID
    }
    
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
                    Button("재등록") {
                        viewModel.updatePost(postID: post.postID, groupID: groupID, title: title, content: content, writer: writer, createdAt: post.createdAt)
                        
                        dismiss()
                    }
                    .disabled(title.isEmpty || writer.isEmpty || groupID.isEmpty)
                }
            }
        }
    }
}
