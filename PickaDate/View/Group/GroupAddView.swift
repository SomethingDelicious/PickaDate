//
//  GroupAddView.swift
//  Pickadate
//
//  Created by mwpark on 2/21/25.
//

import SwiftUI

struct GroupAddView: View {
    @State private var groupName: String = ""
    @State private var leader: String = ""
    @State private var members: [String] = []
    
    @State var showImagePicker = false
    @State var selectedUIImage: UIImage?
    @State var image: Image?
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showUserSearch = false
    
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
                
                // 그룹장 이름 입력
                Text("그룹장 이름")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)
                
                TextField("", text: $leader)
                    .frame(width: 350, height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                
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
                        
                        // 선택된 멤버 표시
                        ForEach(members, id: \.self) { member in
                            VStack {
                                Text(member)
                                    .foregroundStyle(.black)
                                    .padding(8)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.green, lineWidth: 1)
                                    )
                                
                                // 삭제 버튼
                                Button(action: {
                                    if let index = members.firstIndex(of: member) {
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
                    viewModel.addGroup(groupName: groupName, leader: leader, members: members)
                }, label: {
                    Text("저장")
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 50)
                        .background((groupName == "" || leader == "" || members.isEmpty) ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .padding()
                })
                .disabled(groupName == "" && leader == "")
            }
        } // VStack1
        .sheet(isPresented: $showUserSearch) {
            NavigationView {
                UserSearchComponent(selectedMembers: $members)
            }
        }
    }
}

#Preview {
    GroupAddView()
}
