//
//  GroupAddView.swift
//  Pickadate
//
//  Created by mwpark on 2/21/25.
//

import SwiftUI

struct GroupAddView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var groupName: String = ""
    @State private var leader: String = ""
    @State private var members: [SelectedMember] = []
    
    @State var showImagePicker = false
    @State var selectedUIImage: UIImage?
    @State var image: Image?
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showUserSearch = false // 사용자 검색 시트 상태
    
    @StateObject private var viewModel = GroupViewModel()
    
    func loadImage() {
        guard let selectedImage = selectedUIImage else { return }
        image = Image(uiImage: selectedImage)
    }
    
    var body: some View {
        VStack {
            Text("그룹 추가")
                .font(.title2)
                .fontWeight(.bold)
            Spacer()
            
            // 그룹 이미지 섹션
            Button(action: {
                showImagePicker = true
            }) {
                if let image = image {
                    image
                        .resizable()
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.gray)
                        .overlay(alignment: .bottom, content: {
                            Text("편집")
                                .foregroundStyle(.white)
                                .fontWeight(.bold)
                        })
                }
            }
            .sheet(isPresented: $showImagePicker, onDismiss: {
                loadImage()
            }) {
                ImagePicker(image: $selectedUIImage)
            }
            Spacer()
            
            VStack {
                // 그룹 이름 입력
                Text("그룹 이름")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)

                TextField("", text: $groupName)
                    .frame(width: 350, height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                
                // 그룹장 정보 표시 (초기 설정: 현재 로그인한 사용자)
                Text("그룹장 이름")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)
                
                HStack {
                    Text(userViewModel.currentUser?.userName ?? "로그인 필요")
                        .padding(.horizontal)
                        .padding(.leading, 20)
                        .foregroundColor(.blue)
                }
                .frame(width: 350, height: 50)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(10)
                .padding()
                
                // 그룹원 추가 섹션
                Text("그룹원 추가")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)
                
                // 선택된 그룹원 목록
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        // 그룹원 추가 버튼
                        Button(action: {
                            // 사용자 검색 시트 표시
                            showUserSearch = true
                        }) {
                            VStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 24))
                                Text("추가")
                                    .font(.caption)
                            }
                            .foregroundColor(.blue)
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // 현재 로그인한 사용자 표시
                        if let currentUser = userViewModel.currentUser {
                            VStack {
                                Text(currentUser.userName)
                                    .foregroundStyle(.black)
                                    .padding(8)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                                
                                Text("리더")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        // 선택된 멤버 표시
                        ForEach(members, id: \.userID) { member in
                            VStack {
                                Text(member.userName)
                                    .foregroundStyle(.black)
                                    .padding(8)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green, lineWidth: 1)
                                    )
                                
                                // 삭제 버튼
                                Button(action: {
                                    if let index = members.firstIndex(where: { $0.userID == member.userID }) {
                                        members.remove(at: index)
                                    }
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.system(size: 18))
                                }
                            }
                        }
                            
                    }
                }
                .padding()
                
                // 저장 버튼
                Button(action: {
                    // 그룹 추가
                    if let currentUser = userViewModel.currentUser {
                        // 멤버 이름과 ID 목록 준비
                        var memberNames = members.map { $0.userName }
                        var memberIDs = members.map { $0.userID }
                        
                        // 현재 사용자가 멤버 목록에 없으면 추가
                        if !memberNames.contains(currentUser.userName) {
                            memberNames.append(currentUser.userName)
                        }
                        if !memberIDs.contains(currentUser.userID) {
                            memberIDs.append(currentUser.userID)
                        }

                        // 그룹 추가 함수 호출
                        viewModel.addGroup(
                            groupName: groupName,
                            leader: currentUser.userName,
                            leaderID: currentUser.userID,
                            members: memberNames,
                            memberIDs: memberIDs
                        )
                        
                        dismiss()
                    }
                }, label: {
                    Text("저장")
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 50)
                        .background((groupName == "" || userViewModel.currentUser == nil) ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .padding()
                })
                .disabled(groupName.isEmpty || userViewModel.currentUser == nil)
            }
        } // VStack1
        .sheet(isPresented: $showUserSearch) {
            NavigationView {
                UserSearchComponent(selectedMembers: $members)
                    .environmentObject(userViewModel) // UserViewModel 전달
            }
        }
        .onAppear {
            // 화면이 나타날 때 사용자 정보 확인
            if userViewModel.currentUser == nil {
                Task {
                    try? await userViewModel.fetchCurrentUser()
                }
            }
        }
    }
}

#Preview {
    GroupAddView()
}
