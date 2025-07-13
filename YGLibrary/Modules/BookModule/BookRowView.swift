//
//  BookRowView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI
import Kingfisher

struct BookRowView: View {
    let book: Book
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                // 책 이미지
                AsyncImage(url: book.thumbnail) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "book.closed")
                                .foregroundColor(.gray)
                                .font(.title2)
                        )
                }
                .frame(width: 60, height: 85)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // 책 정보
                VStack(alignment: .leading, spacing: 4) {
                    // 카테고리 태그
                    Text("도서")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Capsule())
                    
                    // 책 제목
                    Text(book.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    
                    // 출판사
                    HStack(spacing: 4) {
                        Text("출판사")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(book.publisher)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                    }
                    
                    // 저자
                    HStack(spacing: 4) {
                        Text("저자")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(book.authors.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.primary)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                
                Spacer()
                
                // 우측 영역 (즐겨찾기 + 가격)
                VStack(alignment: .trailing, spacing: 8) {
                    // 즐겨찾기 버튼
                    Button(action: onFavoriteToggle) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(isFavorite ? .red : .gray)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(Color(UIColor.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                    
                    // 가격
                    VStack(alignment: .trailing, spacing: 2) {
                        if book.pricing.salePrice < book.pricing.originPrice {
                            Text(book.pricing.displayOriginPrice)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .strikethrough()
                        }
                        
                        Text(book.pricing.salePrice < book.pricing.originPrice ? 
                             book.pricing.displaySalePrice : book.pricing.displayOriginPrice)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(16)
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    let mockBook = Book(
        id: "123",
        title: "SwiftUI 완벽 가이드: 선언적 UI 프레임워크로 iOS 앱 개발하기",
        contents: "SwiftUI는 애플의 새로운 UI 프레임워크로...",
        url: URL(string: "https://example.com"),
        isbn: "9791162245385",
        dateTime: Date(),
        authors: ["김민수", "이영희"],
        publisher: "한빛미디어",
        translators: [],
        pricing: Book.Pricing(originPrice: 32000, salePrice: 28800),
        thumbnail: URL(string: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5382910"),
        status: "정상판매"
    )
    
    VStack(spacing: 16) {
        BookRowView(
            book: mockBook,
            isFavorite: false,
            onTap: {},
            onFavoriteToggle: {}
        )
        
        BookRowView(
            book: mockBook,
            isFavorite: true,
            onTap: {},
            onFavoriteToggle: {}
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}