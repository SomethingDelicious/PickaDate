//
//  AddPostView.swift
//  PickaDate
//
//  Created by mwpark on 2/23/25.
//
import SwiftUI
import PhotosUI

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = PostViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @State private var title = ""
    @State private var content = ""
    @State private var writer = "익명"
    @State private var groupID = ""
    @State private var groupName = ""
    @State private var writerID = ""
    
    // 이미지 관련 변수
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var imageSelected: Bool = false
    @State private var base64ImageString: String? = nil
    
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
                        
                        // 이미지 미리보기 + X 버튼
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
                                        writerID = currentUser.userID
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
                }
            }
            // onchange deprecated되어서 task 사용
            // 이미지를 선택할 때마다 base64로 인코딩하여 base64ImageString 변수에 저장
            .task(id: selectedItem) {
                if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    
                    // 이미지 파일을 base64 인코딩
                    let base64String = data.base64EncodedString()
                    base64ImageString = base64String
                } else {
                    print("이미지 로드 실패")
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
                        viewModel.addPost(groupID: groupID, groupName: groupName, title: title, content: content, writer: writer, writerID: writerID, image: base64ImageString)
                        dismiss()
                    }
                    .disabled(title.isEmpty || writer.isEmpty || groupID.isEmpty)
                }
            }
        }
    }
}


