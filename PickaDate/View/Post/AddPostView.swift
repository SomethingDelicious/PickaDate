//
//  AddPostView.swift
//  TestGithub
//
//  Created by NoelMacMini on 2/26/25.
//

import SwiftUI

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
