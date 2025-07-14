//
//  KoreanSearchUtils.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

enum MatchType {
    case exactMatch    // 일반 텍스트 매칭
    case choseongMatch // 초성 매칭
    case noMatch       // 매칭 없음
}

struct KoreanSearchUtils {
    private static let choseong = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    static func extractChoseong(from text: String) -> String {
        return text.compactMap { char in
            extractChoseongFromChar(char)
        }.joined()
    }
    
    private static func extractChoseongFromChar(_ char: Character) -> String? {
        let scalar = char.unicodeScalars.first?.value ?? 0
        
        if scalar >= 0xAC00 && scalar <= 0xD7A3 {
            let choseongIndex = Int((scalar - 0xAC00) / 588)
            return choseong[choseongIndex]
        }
        
        if choseong.contains(String(char)) {
            return String(char)
        }
        
        return String(char)
    }
    
    static func matches(text: String, query: String) -> Bool {
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased()
        
        if normalizedText.contains(normalizedQuery) {
            return true
        }
        
        return choseongSequenceMatches(text: text, query: query)
    }
    
    private static func choseongSequenceMatches(text: String, query: String) -> Bool {
        let isQueryAllChoseong = query.allSatisfy { choseong.contains(String($0)) }
        guard isQueryAllChoseong else { return false }
        
        let textChoseong = extractChoseong(from: text)
        return textChoseong.contains(query)
    }
    
    static func getMatchType(text: String, query: String) -> MatchType {
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased()
        
        if normalizedText.contains(normalizedQuery) {
            return .exactMatch
        }
        
        if choseongSequenceMatches(text: text, query: query) {
            return .choseongMatch
        }
        
        return .noMatch
    }
    
    private static func mixedMatches(text: String, query: String) -> Bool {
        return false
    }
    
    static func findMatchRange(in text: String, for query: String) -> Range<String.Index>? {
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased()
        
        return normalizedText.range(of: normalizedQuery)
    }
}

extension String {
    func matchesKoreanSearch(_ query: String) -> Bool {
        return KoreanSearchUtils.matches(text: self, query: query)
    }
    
    var choseong: String {
        return KoreanSearchUtils.extractChoseong(from: self)
    }
}
