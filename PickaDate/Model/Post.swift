//
//  Post.swift
//  PickaDate
//
//  Created by 김태건 on 2/21/25.
//

import SwiftUI
import FirebaseFirestore

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var postID: String          //게시글 ID
    var groupID: String         //그룹 이름
    var title: String           //게시글 제목
    var content: String         //게시글 내용
    var writer: String          //게시글 작성자
    var createdAt: Date         //게시글 생성 날짜
}
