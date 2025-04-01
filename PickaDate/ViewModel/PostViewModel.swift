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
    @Published var posts: [PDPost] = []
    @Published var comments: [String: [PDComment]] = [:] // [postid : 댓글 내용]
    
    // MARK: - 게시판
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
                    try? doc.data(as: PDPost.self)
                } ?? []
                
                for post in self.posts {
                    self.fetchComments(postID: post.postID)
                }
            }
        }
    }
    
    // 게시판 추가하기
    func addPost(groupID: String, groupName: String, title: String, content: String, writer: String, writerID: String, createdAt: Date = Date(), likes: Int = 0, likedUserIDs: [String] = [], likedUserNames: [String] = [], image: String? = nil) {
        let postID = UUID().uuidString
        let postData: [String: Any] = [
            "postID": postID,
            "groupID": groupID,
            "groupName": groupName,
            "title": title,
            "content": content,
            "writer": writer,
            "writerID": writerID,
            "createdAt": FieldValue.serverTimestamp(),
            "likes": likes,
            "likedUserIDs": likedUserIDs,
            "likedUserNames": likedUserNames,
            "image": image ?? ""
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
    
    // 게시판 수정하기
    func updatePost(postID: String, groupID: String, groupName: String, title: String, content: String, writer: String, writerID: String, createdAt: Date, likes: Int, likedUserIDs: [String], likedUserNames:[String], image: String?) {
        let updateData: [String: Any] = [
            "postID": postID,
            "groupID": groupID,
            "groupName": groupName,
            "title": title,
            "content": content,
            "writer": writer,
            "writerID": writerID,
            "createdAt": createdAt,
            "updatedAt": FieldValue.serverTimestamp(),
            "likes": likes,
            "likedUserIDs": likedUserIDs,
            "likedUserNames": likedUserNames,
            "image": image ?? ""
        ]
        
        fsDB.collection("posts").document(postID).updateData(updateData) { error in
            if let error = error {
                print("[E]post 수정 실패: \(error.localizedDescription)")
            } else {
                print("[L]post 수정 성공")
                self.fetchPosts()
            }
        }
    }
    
    // 게시판 삭제하기
    func deletePost(postID: String) {
        // 먼저 해당 게시물의 모든 댓글을 삭제
        fsDB.collection("posts").document(postID)
            .collection("comments").getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    for doc in documents {
                        doc.reference.delete()
                    }
                }
                
                // 그 다음 게시물 삭제
                self.fsDB.collection("posts").document(postID).delete { error in
                    if let error = error {
                        print("[E]post 삭제 실패: \(error.localizedDescription)")
                    } else {
                        print("[L]post 삭제 성공")
                        DispatchQueue.main.async {
                            self.posts.removeAll { $0.postID == postID }
                            self.comments.removeValue(forKey: postID)
                        }
                    }
                }
            }
    }
    
    // MARK: - 댓글
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
                        try? doc.data(as: PDComment.self)
                    } ?? []
                }
            }
    }
    
    // 댓글 추가하기
    func addComment(postID: String, content: String, writer: String, writerID: String) {
        let commentID = UUID().uuidString
        let data: [String: Any] = [
            "commentID": commentID,
            "content": content,
            "writer": writer,
            "writerID": writerID,
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

    // 댓글 수정하기
    func updateComment(postID: String, commentID: String, content: String) {
        let updateData: [String: Any] = [
            "content": content,
            "updatedAt": FieldValue.serverTimestamp()
        ]
        
        fsDB.collection("posts").document(postID)
            .collection("comments").document(commentID)
            .updateData(updateData) { error in
                if let error = error {
                    print("[E]댓글 수정 실패: \(error.localizedDescription)")
                } else {
                    print("[L]댓글 수정 성공")
                    self.fetchComments(postID: postID)
                }
            }
    }

    // 댓글 삭제하기
    func deleteComment(postID: String, commentID: String) {
        fsDB.collection("posts").document(postID)
            .collection("comments").document(commentID)
            .delete { error in
                if let error = error {
                    print("[E]댓글 삭제 실패: \(error.localizedDescription)")
                } else {
                    print("[L]댓글 삭제 성공")
                    DispatchQueue.main.async {
                        self.comments[postID]?.removeAll { $0.commentID == commentID }
                    }
                }
            }
    }
    
    // MARK: - 그 외
    // Date 타입을 String 타입으로 변환
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
