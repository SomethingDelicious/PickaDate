//
//  Post.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct PDPost: Identifiable, Codable {
    @DocumentID var id: String?
    var postID: String          //게시글 ID
    var groupID: String         //그룹 ID
    var groupName: String       //그룹 이름
    var title: String           //게시글 제목
    var content: String         //게시글 내용
    var writer: String          //게시글 작성자
    var writerID: String        //게시글 작성자 ID
    var createdAt: Date         //게시글 생성 날짜
    var likes: Int              //좋아요 갯수
    var likedUserIDs: [String]  //좋아요 누른 사람들의 ID
    var likedUserNames: [String] // 좋아요 누른 사람들의 userName
    var image: String?          // 이미지
}
