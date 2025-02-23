//
//  PostViewModel.swift
//  PickaDate
//
//  Created by mwpark on 2/23/25.
//

import SwiftUI
import FirebaseFirestore

class PostViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var posts: [Post] = []
    @Published var comments: [String: [Comment]] = [:] // [postid : 댓글 내용]
    
    // 게시판 정보 가져오기
    func fetchPosts() {
        fsDB.collection("posts").getDocuments { snapshot, error in
            if let error = error {
                print("[E]post 가져오기 실패: \(error.localizedDescription)")
                return
            }
            print("[L]post 가져오기 성공")
            DispatchQueue.main.async {
                self.posts = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Post.self)
                } ?? []
                
                for post in self.posts {
                    self.fetchComments(postID: post.postID)
                }
            }
        }
    }
    
    // 댓글 가져오기
    func fetchComments(postID: String) {
        fsDB.collection("posts").document(postID)
            .collection("comments").getDocuments{
             snapshot, error in
                if let error = error {
                    print("[E]댓글 가져오기 실패: \(error.localizedDescription)")
                    return
                }
                print("[L]댓글 가져오기 성공")
                DispatchQueue.main.async {
                    self.comments[postID] = snapshot?.documents.compactMap { doc in
                        try? doc.data(as: Comment.self)
                    } ?? []
                }
            }
    }
    
    // 게시판 추가하기
    func addPost(groupID: String, title: String, content: String, writer: String, createdAt: Date = Date()) {
        let postID = UUID().uuidString
        let postData: [String: Any] = [
            "postID": postID,
            "groupID": groupID,
            "title": title,
            "content": content,
            "writer": writer,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        fsDB.collection("posts").document(postID).setData(postData) { error in
            if let error = error {
                print("[E]post 추가 실패: \(error.localizedDescription)")
            } else {
                print("[L]post 추가 성공")
                self.fetchPosts()
            }
        }
    }
    
    // 댓글 추가하기
    func addComment(postID: String, content: String, writer: String) {
        let commentID = UUID().uuidString
        let data: [String: Any] = [
            "commentID": commentID,
            "content": content,
            "writer": writer,
            "createdAt": FieldValue.serverTimestamp()
        ]
        
        fsDB.collection("posts").document(postID)
            .collection("comments").document(commentID)
            .setData(data) { error in
                if let error = error {
                    print("[E]댓글 추가 실패: \(error.localizedDescription)")
                } else {
                    print("[L]댓글 추가 성공")
                    self.fetchComments(postID: postID)
                }
            }
    }
    
    // Date 타입을 String 타입으로 변환
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
