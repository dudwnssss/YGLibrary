//
//  BookDetailView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

import Kingfisher

struct BookDetailView: View {
    @StateObject var store: BookDetailStore
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // 메인 책 정보 섹션
                bookHeaderSection
                
                // 상세 정보 섹션
                bookDetailsSection
                
                // 책 소개 섹션
                bookDescriptionSection
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground))
        .ygToolbar {
            YGToolbarItem.leading {
                Button(action: {
                    store.dispatch(.pop)
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            
            YGToolbarItem.trailing {
                Button(action: {
                    store.dispatch(.toggleFavorite)
                }) {
                    Image(systemName: store.state.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(store.state.isFavorite ? .red : .gray)
                }
                .disabled(store.state.isLoading)
                .opacity(store.state.isLoading ? 0.6 : 1.0)
            }
        }
        .onAppear {
            store.dispatch(.onAppear)
        }
    }
    
    // MARK: - Subviews
    
    private var bookHeaderSection: some View {
        HStack(alignment: .top, spacing: 16) {
            // 책 이미지
            KFImage(store.state.book.thumbnail)
                .placeholder {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "book.closed")
                                .foregroundColor(.gray)
                                .font(.title)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 140, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            
            // 책 정보
            VStack(alignment: .leading, spacing: 12) {
                // 제목
                Text(store.state.book.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // 저자
                VStack(alignment: .leading, spacing: 4) {
                    Text("저자")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(store.state.book.authors.joined(separator: ", "))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                // 출판사
                VStack(alignment: .leading, spacing: 4) {
                    Text("출판사")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    Text(store.state.book.publisher)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                // 출간일
                if let dateTime = store.state.book.dateTime {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("출간일")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        Text(DateFormatter.formatter(style: .full).string(from: dateTime))
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
                
                Spacer()
            }
            
            Spacer(minLength: 0)
        }
    }
    
    private var bookDetailsSection: some View {
        VStack(spacing: 16) {
            // 섹션 제목
            HStack {
                Text("상세 정보")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // 정보 카드
            VStack(spacing: 0) {
                DetailRowView(label: "ISBN", value: store.state.book.isbn)
                
                Divider()
                    .padding(.horizontal, 16)
                
                DetailRowView(
                    label: "정상가", 
                    value: store.state.book.pricing.displayOriginPrice,
                    valueColor: store.book.hasDiscount ? .secondary : .primary,
                    isStrikethrough: store.book.hasDiscount
                )
                
                if store.book.hasDiscount {
                    Divider()
                        .padding(.horizontal, 16)
                    
                    DetailRowView(
                        label: "할인가", 
                        value: store.state.book.pricing.displaySalePrice,
                        valueColor: .red,
                        valueWeight: .bold
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
            )
        }
    }
    
    private var bookDescriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 섹션 제목
            HStack {
                Text("책 소개")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // 내용
            Text(store.state.book.contents)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(UIColor.secondarySystemGroupedBackground))
                )
        }
    }
}

struct DetailRowView: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    var valueWeight: Font.Weight = .medium
    var isStrikethrough: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: valueWeight))
                .foregroundColor(valueColor)
                .strikethrough(isStrikethrough)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
