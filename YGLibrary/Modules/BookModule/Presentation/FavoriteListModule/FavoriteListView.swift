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
        VStack(spacing: .zero) {
            searchButtonView
            
            Group {
                if store.state.isLoading {
                    loadingView
                    
                } else if store.allBooks.isEmpty {
                    emptyFavoritesView
                    
                } else if store.books.isEmpty && !store.query.isEmpty {
                    emptyFilterView
                    
                } else {
                    contentView
                }
            }
        }
        .background(Color(uiColor: .systemGray6))
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
    
    private var contentView: some View {
        List {
            FavoriteSortFilterView(store: store)
            ForEach(store.books, id: \.id) { book in
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
        .background(Color(uiColor: .systemGray6))
        .scrollDismissesKeyboard(.immediately)
        .refreshable {
            store.dispatch(.onAppear)
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("즐겨찾기 불러오는 중...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
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
                   
                   if !store.query.isEmpty && store.priceFilter.isEnabled {
                       Text("'\(store.query)' 검색어와 \(store.priceFilter.displayText) 조건에 맞는 책이 없습니다")
                           .font(.system(size: 16))
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineSpacing(2)
                   } else if !store.query.isEmpty {
                       Text("'\(store.query)'와 일치하는 즐겨찾기 책이 없습니다")
                           .font(.system(size: 16))
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineSpacing(2)
                   } else if store.priceFilter.isEnabled {
                       Text("\(store.priceFilter.displayText) 범위에 맞는 책이 없습니다")
                           .font(.system(size: 16))
                           .foregroundColor(.secondary)
                           .multilineTextAlignment(.center)
                           .lineSpacing(2)
                   }
               }
           }
           .frame(maxWidth: .infinity, maxHeight: .infinity)
       }
        
    private var searchButtonView: some View {
        Button(action: {
            store.dispatch(.openSearchModal)
        }) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack {
                    if store.query.isEmpty {
                        Text("제목 또는 저자를 입력하세요")
                            .foregroundColor(.secondary)
                    } else {
                        Text(store.query)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .font(.system(size: 16))
                
                if !store.query.isEmpty {
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
