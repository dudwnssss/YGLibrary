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
    // 한글 초성
    private static let choseong = [
        "ㄱ", "ㄲ", "ㄴ", "ㄷ", "ㄸ", "ㄹ", "ㅁ", "ㅂ", "ㅃ", "ㅅ",
        "ㅆ", "ㅇ", "ㅈ", "ㅉ", "ㅊ", "ㅋ", "ㅌ", "ㅍ", "ㅎ"
    ]
    
    /// 문자열에서 초성을 추출
    static func extractChoseong(from text: String) -> String {
        return text.compactMap { char in
            extractChoseongFromChar(char)
        }.joined()
    }
    
    /// 단일 문자에서 초성 추출
    private static func extractChoseongFromChar(_ char: Character) -> String? {
        let scalar = char.unicodeScalars.first?.value ?? 0
        
        // 한글 완성형 범위 (가-힣)
        if scalar >= 0xAC00 && scalar <= 0xD7A3 {
            let choseongIndex = Int((scalar - 0xAC00) / 588)
            return choseong[choseongIndex]
        }
        
        // 이미 초성인 경우
        if choseong.contains(String(char)) {
            return String(char)
        }
        
        // 영문, 숫자 등은 그대로 반환
        return String(char)
    }
    
    /// 검색어가 텍스트와 매칭되는지 확인 (초성 포함)
    static func matches(text: String, query: String) -> Bool {
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased()
        
        // 1. 일반 텍스트 매칭
        if normalizedText.contains(normalizedQuery) {
            return true
        }
        
        // 2. 초성 매칭 (연속된 초성만)
        return choseongSequenceMatches(text: text, query: query)
    }
    
    /// 연속된 초성 매칭만 확인
    private static func choseongSequenceMatches(text: String, query: String) -> Bool {
        // 쿼리가 모두 초성인지 확인
        let isQueryAllChoseong = query.allSatisfy { choseong.contains(String($0)) }
        guard isQueryAllChoseong else { return false }
        
        let textChoseong = extractChoseong(from: text)
        return textChoseong.contains(query)
    }
    
    /// 매칭 타입 반환 (하이라이트 여부 결정용)
    static func getMatchType(text: String, query: String) -> MatchType {
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased()
        
        // 1. 일반 텍스트 매칭
        if normalizedText.contains(normalizedQuery) {
            return .exactMatch
        }
        
        // 2. 초성 매칭
        if choseongSequenceMatches(text: text, query: query) {
            return .choseongMatch
        }
        
        return .noMatch
    }
    
    /// 혼합 매칭 (일부는 완성형, 일부는 초성) - 제거
    private static func mixedMatches(text: String, query: String) -> Bool {
        // 기존 mixedMatches 로직 제거
        return false
    }
    
    /// 매칭되는 범위 찾기 (하이라이트용) - 일반 매칭만
    static func findMatchRange(in text: String, for query: String) -> Range<String.Index>? {
        let normalizedText = text.lowercased()
        let normalizedQuery = query.lowercased()
        
        // 일반 텍스트 매칭 범위만 반환 (초성 매칭은 하이라이트 안 함)
        return normalizedText.range(of: normalizedQuery)
    }
}

// MARK: - String Extension
extension String {
    /// 한글 초성 검색 매칭
    func matchesKoreanSearch(_ query: String) -> Bool {
        return KoreanSearchUtils.matches(text: self, query: query)
    }
    
    /// 초성 추출
    var choseong: String {
        return KoreanSearchUtils.extractChoseong(from: self)
    }
}
