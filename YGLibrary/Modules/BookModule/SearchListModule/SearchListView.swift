//
//  SearchListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct SearchListView: View {
    @ObservedObject private var store = SearchListStore()
    
    var body: some View {
        VStack(spacing: 0) {
            // 검색바
            SearchBarView(query: store.query) { text in
                store.dispatch(.search(text))
            }
            
            // 메인 콘텐츠
            Group {
                if store.isLoading && store.state.books.isEmpty {
                    // 초기 로딩
                    loadingView
                    
                } else if store.state.books.isEmpty && !store.query.isEmpty {
                    // 검색 결과 없음
                    emptySearchView
                    
                } else if store.state.books.isEmpty {
                    // 초기 상태
                    initialView
                    
                } else {
                    contentView
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .ygToolbar {
            YGToolbarItem.principal {
                Text("검색")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }
        
    private var contentView: some View {
        ZStack(alignment: .bottom) {
            List {
                SearchSortView(store: store)
                
                // 책 목록
                ForEach(store.state.books, id: \.isbn) { book in
                    BookRowView(
                        book: book,
                        isFavorite: store.state.isFavorite(book),
                        onTap: {
                            store.dispatch(.navigateToDetail(book))
                        },
                        onFavoriteToggle: {
                            store.dispatch(.toggleFavorite(book))
                        }
                    )
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                    .onAppear {
                        store.dispatch(.bookAppeared(book))
                    }
                }
                
                // 하단 로딩 인디케이터
                if store.isLoadingMore {
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            SpinnerView()
                                .scaleEffect(0.8)
                            Text("더 많은 책을 불러오는 중...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 20)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
            }
            .listStyle(PlainListStyle())
            .scrollDismissesKeyboard(.immediately)
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("검색 중...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var initialView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("책을 검색해보세요")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("제목이나 저자명으로\n원하는 책을 찾아보세요")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("'\(store.query)'의 철자를 확인해주세요.\n긴 문구의 경우 띄어쓰기 해보세요.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchListView()
}
