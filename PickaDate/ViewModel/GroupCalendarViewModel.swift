//
//  GroupCalendarViewModel.swift
//  PickaDate
//
//  Created by NoelMacMini on 2/23/25.
//

import SwiftUI
import FirebaseFirestore

class GroupCalendarViewModel: ObservableObject {
    private let fsDB = Firestore.firestore()
    @Published var groupSchedule: [PDGroupSchedule] = []
    
    // 그룹스케쥴 가져오기
    func fetchGroupSchedules() {
        fsDB.collection("groupSchedules").getDocuments { snapshot, error in
            if let error = error {
                print("[E]데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            
            DispatchQueue.main.async {
                self.groupSchedule = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: PDGroupSchedule.self)
                } ?? []
            }
        }
    }
}
