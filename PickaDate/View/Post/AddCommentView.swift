//
//  AddCommentView.swift
//  PickaDate
//
//  Created by mwpark on 2/23/25.
//
import SwiftUI

// 댓글 작성 화면
struct AddCommentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostViewModel()
    
    @State private var post: Post
    @State private var content = ""
    @State private var writer = "작성자명"
    
    @State private var isAnonymous: Bool = false
    
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
                    HStack {
                        Button(action: {
                            isAnonymous.toggle()
                            if isAnonymous {
                                writer = "익명"
                            } else {
                                writer = "작성자명"
                            }
                            
                        }, label: {
                            HStack {
                                Image(systemName: isAnonymous ? "checkmark.square":"square")
                                Text("익명")
                            }
                            .foregroundStyle(isAnonymous ? .red : .gray)
                        })
                        
                        if !isAnonymous {
                            TextField("작성자명", text: $writer)
                        }
                    }
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
