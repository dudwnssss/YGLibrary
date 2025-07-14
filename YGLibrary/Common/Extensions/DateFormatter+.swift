//
//  DateFormatter+.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import Foundation

extension DateFormatter {
    enum DateStyle {
        case full       // "yyyy년 MM월 dd일"
        case short      // "yyyy.MM"
        case yearMonth  // "yyyy년 MM월"
        case relative   // "2일 전", "1주 전"
    }
    
    static func formatter(style: DateStyle) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        switch style {
        case .full:
            formatter.dateFormat = "yyyy년 MM월 dd일"
        case .short:
            formatter.dateFormat = "yyyy.MM"
        case .yearMonth:
            formatter.dateFormat = "yyyy년 MM월"
        case .relative:
            formatter.doesRelativeDateFormatting = true
            formatter.dateStyle = .short
        }
        
        return formatter
    }
}
