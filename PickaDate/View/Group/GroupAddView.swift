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
    @State private var member: [String] = []
    // 유저 더미 데이터
    @State private var somethingDeliciousMembers: [String] = ["고지용", "김태건","박민우","심연아","이민서"]
    @State var showImagePicker = false
    @State var selectedUIImage: UIImage?
    @State var image: Image?
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isSelected: Bool = false
    
    // 테스트로 유저가 5명있다고 가정하고 추가한 것
    @State private var selectedLeader: [Bool] = Array(repeating: false, count: 5)
    @State private var selectedMembers: [Bool] = Array(repeating: false, count: 5)
    @State private var setLeader: Bool = false
    @State private var firstSelected: Bool = false
    
    @StateObject private var viewModel = GroupViewModel()
    
    @State private var isPresented: Bool = false
    @State private var isgroupAdded: Bool = false
    
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
                
                Text("그룹장")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        ForEach(0..<5, id: \.self) { num in
                            Button(action: {
                                if leader == somethingDeliciousMembers[num] {
                                    // 같은 사람을 다시 선택하면 선택 해제
                                    selectedLeader[num] = false
                                    leader = ""
                                } else {
                                    // 기존 선택된 사람을 해제하고 새 그룹장 설정
                                    selectedLeader = Array(repeating: false, count: 5)
                                    selectedLeader[num] = true
                                    leader = somethingDeliciousMembers[num]
                                }
                            }, label: {
                                Text(somethingDeliciousMembers[num])
                                    .foregroundStyle(.black)
                                    .padding(8)
                                    .overlay(
                                        Capsule()
                                            .fill(selectedLeader[num] ? Color.green.opacity(0.4) : Color.clear)
                                    )
                            })
                        }
                    }
                }
                .padding()
                
                Text("그룹원")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        ForEach(0..<5) { num in
                            Button(action: {
                                if leader != "" {
                                    selectedMembers[num] = !selectedMembers[num]
                                }
                                
                            }, label: {
                                if !selectedLeader[num] {
                                    Text(somethingDeliciousMembers[num])
                                        .foregroundStyle(.black)
                                        .padding(8)
                                        .overlay(
                                            Capsule()
                                                .fill(selectedMembers[num] ? Color.green.opacity(0.4) : Color.clear)
                                        )
                                }
                            })
                        }
                        
                    }
                }
                .padding()
                Button(action: {
                    for groupCheck in viewModel.groups {
                        if groupCheck.groupName == groupName {
                            isPresented = true
                        }
                    }
                    
                    if !isPresented {
                        for num in (0..<5) {
                            if selectedLeader[num] {
                                continue
                            }
                            
                            if selectedMembers[num] {
                                member.append(somethingDeliciousMembers[num])
                            }
                        }
                        viewModel.addGroup(groupName: groupName, leader: leader, member: member)
                        member.removeAll()
                        isgroupAdded = true
                    }
                }, label: {
                    Text("저장")
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 50)
                        .background((groupName == "" || leader == "") ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .padding()
                })
                .onAppear{
                    viewModel.fetchGroups()
                }
                .disabled(groupName == "" && leader == "")
                
            }
//            .alert(isPresented: $isPresented) {
//                Alert(title: Text("중복된 그룹명입니다."))
//            }
            .alert(isPresented: $isgroupAdded) {
                Alert(title: Text("그룹이 생성되었습니다."))
            }

        }
        
    }
    
}

#Preview {
    GroupAddView()
}
