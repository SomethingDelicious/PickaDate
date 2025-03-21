import SwiftUI

struct GroupListView: View {
    @EnvironmentObject private var groupViewModel: GroupViewModel
    @State private var searchText: String = "" // 검색 텍스트
    @Environment(\.dismiss) private var dismiss // 화면 닫기
    
    var filteredGroups: [PDGroup] {
        if searchText.isEmpty {
            return groupViewModel.groups
        } else {
            return groupViewModel.groups.filter { group in
                group.groupName.lowercased().contains(searchText.lowercased()) ||
                group.leader.lowercased().contains(searchText.lowercased()) ||
                group.members.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 검색 필드
                TextField("그룹을 검색하세요.", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                // 그룹 목록
                List(filteredGroups, id: \.groupID) { group in
                    Button(action: {
                        // 그룹 선택 시 현재 그룹으로 설정
                        groupViewModel.setCurrentGroup(group)
                        dismiss() // 선택 후 화면 닫기
                    }) {
                        GroupRowView(group: group, isSelected: group.groupID == groupViewModel.currentGroup?.groupID)
                    }
                }
                
                // 검색 결과가 없을 때 표시
                if filteredGroups.isEmpty {
                    Text("No groups found.")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("그룹 검색")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("그룹 검색")
                            .font(.system(size: 35, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                groupViewModel.fetchUserGroups()
            }
        }
    }
}

struct GroupRowView: View {
    var group: PDGroup
    var isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(group.groupName)
                    .font(.headline)
                Text("Leader: \(group.leader)")
                    .font(.subheadline)
                Text("Members: \(group.members.joined(separator: ", "))")
                    .font(.body)
            }
            Spacer()
            
            // 현재 선택된 그룹 표시
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
            
        }
        .padding()
        .contentShape(Rectangle()) // 전체 영역 탭 가능하게
    }
}

//#Preview{
//    GroupListView()
//}
