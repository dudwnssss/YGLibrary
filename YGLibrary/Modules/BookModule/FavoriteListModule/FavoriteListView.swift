//
//  FavoriteListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct FavoriteListView: View {
    @StateObject var store = FavoriteListStore()
    
    var body: some View {
        VStack(spacing: 0) {
            searchButtonView
            
            if !store.state.allBooks.isEmpty {
                FavoriteSortFilterView(store: store)
            }
            
            Group {
                if store.state.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("즐겨찾기 불러오는 중...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if store.state.allBooks.isEmpty {
                    // 즐겨찾기가 전혀 없는 상태
                    emptyFavoritesView
                    
                } else if store.state.books.isEmpty && !store.state.query.isEmpty {
                    // 검색 결과 없음
                    emptyFilterView
                    
                } else {
                    // 즐겨찾기 리스트
                    List {
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
                        }
                    }
                    .listStyle(PlainListStyle())
                    .scrollDismissesKeyboard(.immediately)
                    .refreshable {
                        store.dispatch(.onAppear)
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            store.dispatch(.onAppear)
        }
        .ygToolbar {
            YGToolbarItem.principal {
                Text("즐겨찾기")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("즐겨찾기한 책이 없습니다")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("검색에서 마음에 드는 책을\n즐겨찾기에 추가해보세요")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyFilterView: some View {
           VStack(spacing: 20) {
               Image(systemName: "magnifyingglass")
                   .font(.system(size: 50, weight: .light))
                   .foregroundColor(.gray.opacity(0.6))
               
               VStack(spacing: 8) {
                   Text("조건에 맞는 책이 없어요")
                       .font(.system(size: 20, weight: .semibold))
                       .foregroundColor(.primary)
                   
                   if !store.state.query.isEmpty && store.state.priceFilter.isEnabled {
                       Text("'\(store.state.query)' 검색어와 \(store.state.priceFilter.displayText) 조건에 맞는 책이 없습니다")
                           .font(.system(size: 16))
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineSpacing(2)
                   } else if !store.state.query.isEmpty {
                       Text("'\(store.state.query)'와 일치하는 즐겨찾기 책이 없습니다")
                           .font(.system(size: 16))
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineSpacing(2)
                   } else if store.state.priceFilter.isEnabled {
                       Text("\(store.state.priceFilter.displayText) 범위에 맞는 책이 없습니다")
                           .font(.system(size: 16))
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineSpacing(2)
                   }
               }
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
       }
    
    // MARK: - Search Button View
    
    private var searchButtonView: some View {
        Button(action: {
            store.dispatch(.openSearchModal)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack {
                    if store.state.query.isEmpty {
                        Text("제목 또는 저자를 입력하세요")
                            .foregroundColor(.secondary)
                    } else {
                        Text(store.state.query)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .font(.system(size: 16))
                
                if !store.state.query.isEmpty {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .onTapGesture {
                            store.dispatch(.search(""))
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .background(.white)
    }
}
