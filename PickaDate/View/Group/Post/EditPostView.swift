//
//  EditPostView.swift
//  PickaDate
//
//  Created by mwpark on 2/24/25.
//

import SwiftUI
import PhotosUI

struct EditPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostViewModel()
    //    @StateObject private var groupViewModel = GroupViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var post: PDPost
    @State private var title: String
    @State private var content: String
    @State private var writer: String
    @State private var writerID: String
    @State private var groupID: String
    @State private var groupName: String
    @State private var likes: Int
    @State private var likedUserIDs: [String]
    @State private var likedUserNames: [String]
    
    
    // 이미지 관련 변수
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var imageSelected: Bool = false
    @State private var base64ImageString: String? = nil
    // base64 → 복원된 이미지
    @State private var image: String
    @State private var restoredImage: UIImage? = nil
    
    
    init(post: PDPost) {
        self.post = post
        title = post.title
        content = post.content
        writer = post.writer
        writerID = post.writerID
        groupID = post.groupID
        groupName = post.groupName
        likes = post.likes
        likedUserIDs = post.likedUserIDs
        likedUserNames = post.likedUserNames
        image = post.image ?? ""
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("제목")) {
                    TextField("제목을 입력하세요", text: $title)
                }
                
                Section(header: Text("내용")) {
                    VStack {
                        TextEditor(text: $content)
                            .padding(.vertical, 4)
                        
                        // 복원할 이미지가 있는 경우(게시글에 이미지가 있는경우)
                        if let image = restoredImage {
                            ZStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                                
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            selectedImageData = nil
                                            restoredImage = nil
                                            base64ImageString = nil
                                            viewModel.updatePost(postID: post.postID, groupID: groupID, groupName: groupName, title: title, content: content, writer: writer, writerID: writerID, createdAt: post.createdAt, likes: likes, likedUserIDs: likedUserIDs, likedUserNames: likedUserNames, image: base64ImageString)
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title2)
                                                .foregroundColor(.gray)
                                                .padding(8)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                        } else {
                            // 이미지 미리보기 + X 버튼
                            // 기존 이미지를 삭제하고 새로운 이미지를 추가하는 경우
                            if let data = selectedImageData,
                               let uiImage = UIImage(data: data) {
                                ZStack {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxHeight: 200)
                                        .cornerRadius(8)
                                    
                                    VStack {
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                selectedImageData = nil
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                                    .padding(8)
                                            }
                                        }
                                        Spacer()
                                    }
                                }
                            }
                            
                            // 이미지 선택 버튼
                            PhotosPicker(
                                selection: $selectedItem,
                                matching: .images,
                                photoLibrary: .shared()
                                
                            ) {
                                Image(systemName: "camera")
                                    .font(.subheadline)
                                    .padding(6)
                            }
                            
                        }
                        
                        
                    }
                }
                
                if let currentUser = userViewModel.currentUser {
                    Section(header: Text("작성자")) {
                        Text(currentUser.userName)
                    }
                    
                    Section(header: Text("작성자 그룹")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .center) {
                                ForEach(currentUser.joinedGroups, id: \.self) { group in
                                    Button(action: {
                                        writer = currentUser.userName
                                        groupName = group
                                        if let index = currentUser.joinedGroups.firstIndex(of: group),
                                           index < currentUser.joinedGroupUIDs.count {
                                            groupID = currentUser.joinedGroupUIDs[index]
                                        }
                                    }) {
                                        Text(group)
                                            .foregroundStyle(.black)
                                            .padding(8)
                                            .background(
                                                groupName == group ? Color.gray.opacity(0.3) : Color.clear
                                            )
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    ProgressView("사용자 정보를 불러오는 중...")
                }
            }
            .onAppear {
                Task {
                    try await userViewModel.fetchCurrentUser()
                    // base64 → 복원된 이미지
                    if image != "" {
                        if let decodedData = Data(base64Encoded: image),
                           let uiImage = UIImage(data: decodedData) {
                            restoredImage = uiImage
                        }
                    }
                }
            }
            .task(id: selectedItem) {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    
                    // base64 인코딩
                    // 기존 사진이 아니라 새로운 사진을 선택할 경우
                    let base64String = data.base64EncodedString()
                    base64ImageString = base64String
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
                        viewModel.updatePost(postID: post.postID, groupID: groupID, groupName: groupName, title: title, content: content, writer: writer, writerID: writerID, createdAt: post.createdAt, likes: likes, likedUserIDs: likedUserIDs, likedUserNames: likedUserNames, image: base64ImageString)
                        dismiss()
                    }
                    .disabled(title.isEmpty || writer.isEmpty || groupID.isEmpty)
                }
            }
        }
    }
}
