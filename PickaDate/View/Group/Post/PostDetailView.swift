import SwiftUI

struct PostDetailView: View {
    let postID: String
    @State private var commentID: String = ""
    @StateObject private var viewModel = PostViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var newCommentText = ""
    
    // sheet창
    @State private var showingEditPost: Bool = false
    @State private var showingLikedUserNames: Bool = false
    
    // alert창
    @State private var showingCommentForm = false
    @State private var showingDeletePostAlert: Bool = false
    @State private var showingDeleteCommentAlert: Bool = false
    @State private var showingReportPostAlert: Bool = false
    @State private var showingReportCommentAlert: Bool = false
    @State private var showingCompleteReportAlert: Bool = false
    
    // 좋아요 여부
    @State private var isLiked: Bool
    
    // 게시판
    @State private var groupID: String
    @State private var title: String
    @State private var content: String
    @State private var writer: String
    @State private var writerID: String
    @State private var createdAt: Date
    @State private var likes: Int
    
    // 댓글
    @State private var isAnonymous: Bool = false
    @StateObject private var userViewModel = UserViewModel()
    @State private var commentContent = ""
    @State private var commentWriter = ""
    @State private var commentWriterID = ""
    
    // 좋아요 애니메이션
    @State private var likeButtonScale: CGFloat = 1.0
    
    // 신고된 게시글, 댓글 ID
    @State private var reportedPostID: String = ""
    @State private var reportedCommentID: String = ""
    
    // 좋아요, 신고를 누른 유저의 ID
    @State private var likedUserIDs: [String] = []
    @State private var likedUserNames: [String] = []
    
    // 이미지
    @State private var base64ImageString: String = ""
    @State private var image: UIImage? = nil
    
    
    init(post: PDPost) {
        self.postID = post.postID
        _groupID = State(initialValue: post.groupID)
        _title = State(initialValue: post.title)
        _content = State(initialValue: post.content)
        _writer = State(initialValue: post.writer)
        _writerID = State(initialValue: post.writerID)
        _createdAt = State(initialValue: post.createdAt)
        _likes = State(initialValue: post.likes)
        _likedUserIDs = State(initialValue: post.likedUserIDs)
        _likedUserNames = State(initialValue: post.likedUserNames)
        _isLiked = State(initialValue: post.likedUserIDs.contains(post.writerID))
        _base64ImageString = State(initialValue: post.image ?? "")
    }
    
    // 현재 post를 계산 프로퍼티로 구현
    private var post: PDPost {
        viewModel.posts.first { $0.postID == postID } ?? PDPost(postID: "", groupID: "", groupName: "", title: "", content: "", writer: "", writerID: "", createdAt: Date(), likes: 0, likedUserIDs: [], likedUserNames: [])
    }
    
    var body: some View {
        ScrollView {
            if let currentUser = userViewModel.currentUser {
                VStack(alignment: .leading, spacing: 16) {
                    // 게시물 내용
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(post.writer)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatDate(post.createdAt))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Text(post.content)
                            .padding(.vertical, 8)
                        if let contentImage = image {
                                Image(uiImage: contentImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // 좋아요 & 댓글
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Button(action: {
                                isLiked.toggle()
                                likes += isLiked ? 1 : -1
                                
                                if isLiked {
                                    if !likedUserIDs.contains(currentUser.userID) {
                                        likedUserIDs.append(currentUser.userID)
                                        likedUserNames.append(currentUser.userName)
                                    }
                                } else {
                                    likedUserIDs.removeAll { $0 == currentUser.userID }
                                    likedUserNames.removeAll { $0 == currentUser.userName }
                                }
                                // 애니메이션 적용을 약간 지연시켜 뷰 리렌더링 이후에 실행되도록
                                // 애니메이션이 뷰 갱신과 동기화 되지 않는 문제 해결
                                DispatchQueue.main.async {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                                        likeButtonScale = 3
                                    }
                                    
                                    // 원래 크기로 돌아오기
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        withAnimation {
                                            likeButtonScale = 1.0
                                        }
                                    }
                                }
                                viewModel.updatePost(postID: postID, groupID: post.groupID, groupName: post.groupName, title: post.title, content: post.content, writer: post.writer, writerID: post.writerID, createdAt: post.createdAt, likes: likes, likedUserIDs: likedUserIDs, likedUserNames: likedUserNames, image: base64ImageString)

                            }) {
                                HStack{
                                    Image(systemName: isLiked ? "heart.fill" :"heart")
                                        .foregroundStyle(.red)
                                        .scaleEffect(likeButtonScale)
                                    
                                    Text("\(likes) ")
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                }
                                
                            }
                            HStack{
                                Image(systemName: "message")
                                    .foregroundStyle(.blue)
                                Text("\(viewModel.comments[postID]?.count ?? 0)")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                            }
                            Spacer()
                        }
                        if likedUserIDs.isEmpty {
                            
                        } else {
                            if likedUserIDs.count == 1 {
                                Text("\(likedUserNames[0])님이 좋아합니다")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                            } else {
                                HStack {
                                    Text("\(likedUserNames[0])님 외")
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                    Button(action: {
                                        showingLikedUserNames = true
                                    }, label: {
                                        Text("여러 명")
                                            .font(.headline)
                                    })
                                    Text("이 좋아합니다")
                                        .font(.headline)
                                        .foregroundStyle(.black)
                                }

                            }
                        }
                        
                        // 댓글들
                        if (viewModel.comments[postID]?.count ?? 0) == 0 {
                            Text("아직 댓글이 없습니다.")
                                .foregroundColor(.gray)
                                .padding(.vertical, 8)
                        } else {
                            ForEach(viewModel.comments[postID]?.sorted(by: { $0.createdAt < $1.createdAt }) ?? [], id: \.id) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(comment.writer)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(comment.writer.contains("글쓴이") ? .blue : .black)
                                        
                                        Spacer()
                                        
                                        Text(formatDate(comment.createdAt))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        
                                        Menu {
                                            // 게시글 작성자만 삭제 가능
                                            if currentUser.userID == comment.writerID {
                                                Button(role: .destructive) {
                                                    showingDeleteCommentAlert = true
                                                    commentID = comment.commentID
                                                } label: {
                                                    Label("삭제", systemImage: "trash")
                                                }
                                            } else {
                                                Button(role: .destructive) {
                                                    showingReportCommentAlert = true
                                                    reportedCommentID = comment.commentID
                                                } label: {
                                                    Label("신고", systemImage: "exclamationmark.triangle")
                                                }
                                            }
                                        } label: {
                                            Image(systemName: "ellipsis")
                                                .rotationEffect(.degrees(90))
                                                .font(.caption)
                                                .foregroundColor(.black)
                                                .padding(.leading, 4)
                                        }
                                    }
                                    
                                    Text(comment.content)
                                        .padding(.top, 2)
                                }
                                .padding()
                                .background(.gray.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            } else {
                ProgressView("사용자 정보를 불러오는 중...")
            }
        }
        
        // MARK: - 댓글 입력 창
        VStack {
            HStack {
                if let currentUser = userViewModel.currentUser {
                    Button(action: {
                        isAnonymous.toggle()
                    }) {
                        HStack {
                            Image(systemName: isAnonymous ? "checkmark.square" : "square")
                            Text("익명")
                        }
                        .foregroundStyle(isAnonymous ? .red : .gray)
                    }
                    
                    TextField("댓글을 입력하세요.", text: $commentContent)
                    
                    Button(action: {
                        if !commentContent.isEmpty {
                            commentWriter = (isAnonymous ? "익명" : currentUser.userName)
                            
                            // 댓글 작성자가 게시글 작성자인 경우
                            if post.writerID == currentUser.userID {
                                commentWriter = isAnonymous ? "익명(글쓴이)":"글쓴이"
                            }
                            commentWriterID = currentUser.userID
                            viewModel.addComment(postID: postID, content: commentContent, writer: commentWriter, writerID: commentWriterID)
                            isAnonymous = false
                            commentContent = ""
                            commentWriter = currentUser.userName
                        }
                        viewModel.fetchPosts()
                    }) {
                        Image(systemName: "paperplane")
                            .foregroundStyle(.red)
                    }
                    .disabled(commentContent.isEmpty)
                } else {
                    ProgressView("사용자 정보를 불러오는 중...")
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(10)
            .frame(height: 40)
        }
        // MARK: - Toolbar & Sheet & Alert
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(post.title)
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            ToolbarItem(placement: .primaryAction) {
                if let currentUser = userViewModel.currentUser {
                    Menu {
                        if currentUser.userID == post.writerID {
                            Button {
                                showingEditPost = true
                            } label: {
                                Label("수정", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                showingDeletePostAlert = true
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        } else {
                            Button(role: .destructive) {
                                showingReportPostAlert = true
                                reportedPostID = post.postID
                            } label: {
                                Label("신고", systemImage: "exclamationmark.triangle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .rotationEffect(.degrees(90))
                    }
                    
                } else {
                    ProgressView("사용자 정보를 불러오는 중...")
                }
                
            }
        }
        .onAppear {
            Task {
                try await userViewModel.fetchCurrentUser()
                viewModel.fetchPosts()
                
                // base64(String)으로 저장된 값을 UIImage타입(사진)으로 디코딩하여 image 변수에 저장
                if base64ImageString != "" {
                    if let decodedData = Data(base64Encoded: base64ImageString),
                       let uiImage = UIImage(data: decodedData) {
                        image = uiImage
                    }
                }
                
                // async aswit 안 쓰려고 0.5초 뒤에 실행 되도록 함.
                // 수정 필요할 듯.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if let currentUser = userViewModel.currentUser,
                       let post = viewModel.posts.first(where: { $0.postID == postID }) {
                        isLiked = post.likedUserIDs.contains(currentUser.userID)
                    }
                }
            }
        }
        .refreshable {
            viewModel.fetchPosts()
        }
        .sheet(isPresented: $showingEditPost, onDismiss: {
            viewModel.fetchPosts()
        }) {
            EditPostView(post: post)
        }
        .sheet(isPresented: $showingLikedUserNames) {
            ShowLikedUserNames(likedUserNames: likedUserNames)
        }
        .alert("이 게시물을 삭제합니다.", isPresented: $showingDeletePostAlert) {
            Button("취소하기", role: .cancel) { }
            Button("삭제하기", role: .destructive) {
                viewModel.deletePost(postID: postID)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .alert("이 댓글을 삭제합니다.", isPresented: $showingDeleteCommentAlert) {
            Button("취소하기", role: .cancel) { }
            Button("삭제하기", role: .destructive) {
                viewModel.deleteComment(postID: postID, commentID: commentID)
            }
        }
        .alert("이 게시물을 신고합니다.", isPresented: $showingReportPostAlert) {
            Button("취소하기", role: .cancel) { }
            Button("신고하기", role: .destructive) {
                showingCompleteReportAlert = true
                // TODO: 게시글 신고 횟수 넘으면 자동삭제 기능
                
                // 초기화
                reportedPostID = ""
            }
        }
        .alert("이 댓글을 신고합니다.", isPresented: $showingReportCommentAlert) {
            Button("취소하기", role: .cancel) { }
            Button("신고하기", role: .destructive) {
                showingCompleteReportAlert = true
                // TODO: 댓글 신고 횟수 넘으면 자동삭제 기능
                
                // 초기화
                reportedCommentID = ""
            }
        }
        .alert("신고 완료되었습니다.\n일정 신고 횟수가 넘어가면 자동으로 삭제됩니다.", isPresented: $showingCompleteReportAlert) {
            Button("확인", role: .cancel) { }
        }
    }
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
}
