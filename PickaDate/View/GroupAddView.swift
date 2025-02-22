//
//  GroupAddView.swift
//  Pickadate
//
//  Created by mwpark on 2/21/25.
//

import SwiftUI

struct GroupAddView: View {
    @State private var groupID: String = ""
    @State private var leader: String = ""
    @State private var member: [String] = []
    
    @State var showImagePicker = false
    @State var selectedUIImage: UIImage?
    @State var image: Image?
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isSelected: Bool = false
    // 테스트로 유저가 20명있다고 가정하고 추가한 것
    @State private var selectedItems: [Bool] = Array(repeating: false, count: 20)
    
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
                HStack {
                        ForEach(viewModel.groups) { groupData in
                            Text(groupData.groupID)
                                .font(.headline)
                        }
                    }
                TextField("", text: $groupID)
                    .frame(width: 350, height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                
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
                
                Text("그룹원 추가")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 30)
                    .foregroundStyle(.gray)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center) {
                        
                        ForEach(0..<20) { num in
                            Button(action: {
                                selectedItems[num] = !selectedItems[num]
                                member.append("홍길동\(num)")
                            }, label: {
                                // 예제 데이터 입니다.
                                Text("홍길동\(num)")
                                    .foregroundStyle(.black)
                                    .padding(8)
                                    .overlay(
                                        Capsule()
                                            .fill(selectedItems[num] ? Color.green.opacity(0.4) : Color.clear)
                                    )
                                    .animation(.easeInOut, value: selectedItems[num])
                            })
                        }
                        
                    }
                }
                .padding()
                Button(action: {
                    viewModel.addGroup(groupID: groupID, leader: leader, member: member)
                }, label: {
                    Text("저장")
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 50)
                        .background((groupID == "" || leader == "" || member.isEmpty) ? Color.gray : Color.green)
                        .cornerRadius(10)
                        .padding()
                })
                .disabled(groupID == "" && leader == "" && member.isEmpty)

            }
        }
        
    }
}

#Preview {
    GroupAddView()
}
