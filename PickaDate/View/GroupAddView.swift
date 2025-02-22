//
//  GroupAddView.swift
//  Pickadate
//
//  Created by mwpark on 2/21/25.
//

import SwiftUI

struct GroupAddView: View {
    @State private var groupid: String = ""
    @State var showImagePicker = false
    @State var selectedUIImage: UIImage?
    @State var image: Image?
    @State private var imageSourceType: UIImagePickerController.SourceType = .photoLibrary
    
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
                
                TextField("", text: $groupid)
                    .frame(width: 350, height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .padding()
                    .onAppear {
                        UITextField.appearance().clearButtonMode = .whileEditing
                    }
                
                Button(action: {}, label: {
                    Text("저장")
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 50)
                        .background(Color.green)
                        .cornerRadius(10)
                        .padding()
                })
            }
        }
        
    }
}

#Preview {
    GroupAddView()
}
