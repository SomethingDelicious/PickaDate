//
//  LoginView.swift
//  PickaDate
//
//  Created by 심연아 on 2/22/25.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Image("Sample-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .padding()
                
                VStack {
                    TextField("Enter your email", text: $email)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                    
                    SecureField("Enter your password", text: $password)
                        .font(.subheadline)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal, 24)
                }
                
                NavigationLink {
                    Text("Forgot password")
                } label: {
                    Text("Forgot password?")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.top)
                        .padding(.trailing, 28)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.bottom)
                
                Button {
                    // 로그인 로직 추가
                } label: {
                    Text("Login")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 352, height: 44)
                        .background(.black)
                        .cornerRadius(8)
                }
                
                // 구글 로그인 버튼 추가
                Button {
                    // 구글 로그인 로직 추가
                } label: {
                    HStack {
                        Image("Google-logo") // 구글 아이콘으로 대체
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red) // 아이콘 색상 조정 가능
                        Text("Continue with Google")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .frame(width: 352, height: 44)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.top, 8)
                
                Spacer()
                
                Divider()
                
                NavigationLink {
                    Text("Registration View")
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.black)
                    .font(.footnote)
                }
                .padding(.vertical, 16)
            }
        }
    }
}

#Preview {
    LoginView()
}
