import SwiftUI

struct GroupListView: View {
    @StateObject private var viewModel = GroupViewModel()
    @State private var searchText: String = "" // 검색 텍스트
    
    var filteredGroups: [PDGroup] {
        if searchText.isEmpty {
            return viewModel.groups
        } else {
            return viewModel.groups.filter { group in
                group.groupName.lowercased().contains(searchText.lowercased()) ||
                group.leader.lowercased().contains(searchText.lowercased()) ||
                group.member.contains { $0.lowercased().contains(searchText.lowercased()) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("그룹을 검색하세요.", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                List(filteredGroups, id: \.groupID) { group in
                    GroupRowView(group: group)
                }
                
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
                viewModel.fetchGroups()
            }
        }
    }
}

struct GroupRowView: View {
    var group: PDGroup
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.groupName)
                .font(.headline)
            Text("Leader: \(group.leader)")
                .font(.subheadline)
            Text("Members: \(group.member.joined(separator: ", "))")
                .font(.body)
        }
        .padding()
    }
}

#Preview{
    GroupListView()
}
