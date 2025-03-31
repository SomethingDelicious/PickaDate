//
//  Comment.swift
//  PickaDate
//
//  Created by mwpark on 2/22/25.
//

import SwiftUI
import FirebaseFirestore

struct PDComment: Identifiable, Codable {
    @DocumentID var id: String?
    var commentID: String   // 댓글 ID
    var content: String     // 댓글 내용
    var writer: String      // 작성자
    var writerID: String    // 작성자 ID
    var createdAt: Date     // 작성시간
}
