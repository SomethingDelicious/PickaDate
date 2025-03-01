import SwiftUI

struct GroupListView: View {
    @StateObject private var viewModel = GroupViewModel()
    @State private var searchText: String = "" // 검색 텍스트
    
    @State private var name: String = ""
    
    @State private var selectedGroup: String = ""
    @State private var finalMembers: [String] = []
    
    var filteredGroups: [Group] {
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
                
                List {
                    ForEach(filteredGroups, id: \.groupID) { group in
                        GroupRowView(group: group)
                            .background(selectedGroup == group.groupName ? Color.green.opacity(0.2) : Color.clear)
                            .onTapGesture {
                                selectedGroup = group.groupName
                            }
                        
                        HStack {
                            TextField("추가할 멤버의 이름을 작성하세요.", text: $name)
                            Spacer()
                            Button(action:{
                                if name != "" {
                                    finalMembers = group.member
                                    if group.member.isEmpty {
                                        finalMembers[0] = name
                                    } else {
                                        finalMembers.append(name)
                                    }
                                    viewModel.updateGroup(groupID: group.groupID, groupName: group.groupName, leader: group.leader, member: finalMembers)
                                    name = ""
                                }
                            }, label: {
                                Image(systemName: "person.badge.plus")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            })
                        }
                            .padding()
                            .frame(height: 20)
                        
                    }
                    .onDelete(perform: deleteGroup)
                }
                
                if filteredGroups.isEmpty {
                    Text("그룹이 없습니다.")
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
    
    private func deleteGroup(at offsets: IndexSet) {
        for index in offsets {
            let group = filteredGroups[index]
            viewModel.deleteGroup(groupName: group.groupName)
        }
    }
}

struct GroupRowView: View {
    var group: Group
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(group.groupName)
                .font(.headline)
            Text("Leader: \(group.leader)")
                .font(.body)
            Text("Members: \(group.member.joined(separator: ", "))")
                .font(.body)
        }
        .padding()
    }
}

#Preview{
    GroupListView()
}
