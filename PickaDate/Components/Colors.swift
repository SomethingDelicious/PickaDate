//
//  CommonSchedule.swift
//  PickaDate
//
//  Created by NoelMacMini on 3/3/25.
//

import SwiftUI

// MARK: - 기존 색상 매핑
let colors: [String] = ["red", "orange", "yellow", "green", "blue", "purple", "brown"]
// 색상 매핑
let colorMap: [String: Color] = [
    "red": .red,
    "orange": .orange,
    "yellow": .yellow,
    "green": .green,
    "blue": .blue,
    "purple": .purple,
    "brown": .brown
]

// MARK: - PD 메인테마 색상
// 코드 사용 예시
// .background(Color.pointColor)
// .foregroundColor(Color.pointColor)
// .foregroundStyle(Color.pointColor)
// .tint(Color.pointColor)

extension Color {
    // Main Colors
    static let mainColor = Color(hex: "786154")
    static let subColorOne = Color(hex: "B1926F")
    static let subColorTwo = Color(hex: "BAA78E")
    static let pointColor = Color(hex: "C98A65")
    
    // 기본테마: A59D84, C1BAA1, D7D3BF, ECEBDE
    // 테마2: 786154, B1926F, BAA78E, C98A65
    
    // Gray Scale
    static let gray50Background = Color(hex: "F6F7F8")
    static let gray200Line = Color(hex: "DBDEE2")
    static let gray300Disable = Color(hex: "C9CED3")
    static let gray400 = Color(hex: "A5ACB5")
    static let gray500 = Color(hex: "7E8592")
    static let gray600 = Color(hex: "717784")
    static let gray700 = Color(hex: "5F626E")
    static let gray800 = Color(hex: "4E515A")
    static let gray900 = Color(hex: "323439")
    
    // Utility Colors
    static let redError = Color(hex: "EB003B")
}


// MARK: - hex코드를 이용하기 위한 extension
extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
extension Color {
    init(hex: String) {
        let uiColor = UIColor(hex: hex)
        self.init(uiColor)
    }
    
    init(hex: Int, alpha: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}


