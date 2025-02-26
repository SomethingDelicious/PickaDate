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
    @StateObject private var groupViewModel = GroupViewModel()
    @State private var post: Post
    @State private var title: String
    @State private var content: String
    @State private var writer: String
    @State private var groupID: String
    @State private var likes: Int
    
    init(post: Post) {
        self.post = post
        title = post.title
        content = post.content
        writer = post.writer
        groupID = post.groupID
        likes = post.likes
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
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center) {
                            ForEach(groupViewModel.groups) { group in
                                Button(action: {
                                    groupID = group.groupName
                                }, label: {
                                    // 예제 데이터 입니다.
                                    Text(group.groupName)
                                        .foregroundStyle(.black)
                                        .padding(8)
                                        .background(
                                                    groupID == group.groupName ? Color.gray.opacity(0.3) : Color.clear
                                                )
                                                .cornerRadius(8)
                                })
                            }
                            
                        }
                    }
                    .padding()
                }
            }
            .onAppear{
                groupViewModel.fetchGroups()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("재등록") {
                        viewModel.updatePost(postID: post.postID, groupID: groupID, title: title, content: content, writer: writer, createdAt: post.createdAt, likes: likes)
                        
                        dismiss()
                    }
                    .disabled(title.isEmpty || writer.isEmpty || groupID.isEmpty)
                }
            }
        }
    }
}
