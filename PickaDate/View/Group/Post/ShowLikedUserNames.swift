//
//  ShowLikedUserNames.swift
//  PickaDate
//
//  Created by mwpark on 3/30/25.
//

import SwiftUI

struct ShowLikedUserNames: View {
    @State private var likedUserNames: [String]
    
    init(likedUserNames: [String]) {
        self.likedUserNames = likedUserNames
    }
    
    var body: some View {
        VStack {
            Text("좋아요")
                .font(.title)
                .fontWeight(.bold)
            Divider()
            ForEach(likedUserNames, id: \.self) { likedUserName in
                HStack {
                    Spacer()
                    Image(systemName: "person.circle")
                        .resizable()
                        .foregroundColor(.blue)
                        .frame(width: 30, height: 30)
                    Text(likedUserName)
                        .font(.system(size: 25))
                    Spacer()
                }
                
                
            }
        }
        .padding(30)
    }
}
