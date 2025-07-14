//
//  SearchSuggestionRowView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import SwiftUI

struct SearchSuggestionRowView: View {
    let suggestion: SearchSuggestion
    let query: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Image(systemName: suggestion.type.iconName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(width: 20, height: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    HighlightedText(
                        text: suggestion.text,
                        query: query
                    )
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    
                    Text(suggestion.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - HighlightedText
struct HighlightedText: View {
    let text: String
    let query: String
    
    var body: some View {
        if query.isEmpty {
            Text(text)
        } else {
            let attributedString = createAttributedString()
            Text(attributedString)
        }
    }
    
    private func createAttributedString() -> AttributedString {
        var attributedString = AttributedString(text)
        
        let matchType = KoreanSearchUtils.getMatchType(text: text, query: query)
        
        switch matchType {
        case .exactMatch:
            if let range = text.range(of: query, options: .caseInsensitive) {
                let nsRange = NSRange(range, in: text)
                
                if let attributedRange = Range<AttributedString.Index>(nsRange, in: attributedString) {
                    attributedString[attributedRange].foregroundColor = .blue
                    attributedString[attributedRange].font = .system(size: 16, weight: .semibold)
                }
            }
            
        case .choseongMatch:
            break
            
        case .noMatch:
            break
        }
        
        return attributedString
    }
}

#Preview {
    VStack(spacing: .zero) {
        SearchSuggestionRowView(
            suggestion: SearchSuggestion(
                id: "1",
                text: "SwiftUI 완벽 가이드",
                subtitle: "김민수, 이영희",
                type: .bookTitle,
                book: Book(
                    id: "1",
                    title: "SwiftUI 완벽 가이드",
                    contents: "",
                    url: nil,
                    isbn: "123",
                    dateTime: nil,
                    authors: ["김민수", "이영희"],
                    publisher: "한빛미디어",
                    translators: [],
                    pricing: Book.Pricing(originPrice: 30000, salePrice: 27000),
                    thumbnail: nil,
                    status: ""
                )
            ),
            query: "스위이" // "스위이프트" 연속 초성 매칭 - 하이라이트 없음
        ) {}
        
        Divider()
        
        SearchSuggestionRowView(
            suggestion: SearchSuggestion(
                id: "2",
                text: "김민수",
                subtitle: "저자 • SwiftUI 완벽 가이드",
                type: .author,
                book: Book(
                    id: "1",
                    title: "SwiftUI 완벽 가이드",
                    contents: "",
                    url: nil,
                    isbn: "123",
                    dateTime: nil,
                    authors: ["김민수"],
                    publisher: "한빛미디어",
                    translators: [],
                    pricing: Book.Pricing(originPrice: 30000, salePrice: 27000),
                    thumbnail: nil,
                    status: ""
                )
            ),
            query: "김민" // 일반 텍스트 매칭 - 하이라이트 있음
        ) {}
        
        Divider()
        
        SearchSuggestionRowView(
            suggestion: SearchSuggestion(
                id: "3",
                text: "한빛미디어",
                subtitle: "출판사 • SwiftUI 완벽 가이드",
                type: .publisher,
                book: Book(
                    id: "1",
                    title: "SwiftUI 완벽 가이드",
                    contents: "",
                    url: nil,
                    isbn: "123",
                    dateTime: nil,
                    authors: ["김민수"],
                    publisher: "한빛미디어",
                    translators: [],
                    pricing: Book.Pricing(originPrice: 30000, salePrice: 27000),
                    thumbnail: nil,
                    status: ""
                )
            ),
            query: "ㅍㅂㅁㄷ" // "한빛미디" 연속 초성 매칭 - 하이라이트 없음
        ) {}
    }
    .background(Color(UIColor.systemBackground))
}
