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
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 정렬/필터
            if !store.books.isEmpty || !store.query.isEmpty {
                SearchSortView(store: store)
            }
            
            // 메인 콘텐츠
            Group {
                if store.isLoading && store.books.isEmpty {
                    // 초기 로딩
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("검색 중...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if store.books.isEmpty && !store.query.isEmpty {
                    // 검색 결과 없음
                    emptySearchView
                    
                } else if store.books.isEmpty {
                    // 초기 상태
                    initialView
                    
                } else {
                    // 검색 결과 리스트
                    booksListView
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
    
    // MARK: - Subviews
    
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
    
    private var booksListView: some View {
        List {
            ForEach(store.books, id: \.isbn) { book in
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
                    if book.isbn == store.books.last?.isbn {
                        store.dispatch(.loadNextPage)
                    }
                }
            }
            
            // 추가 로딩 인디케이터
            if store.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(0.9)
                    Text("더 불러오는 중...")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 16)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(PlainListStyle())
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    SearchListView()
}
