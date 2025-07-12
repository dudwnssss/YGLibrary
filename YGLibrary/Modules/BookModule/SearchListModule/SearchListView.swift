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
        YGNavigationView {
            VStack {
                SearchBarView(query: store.query) { text in
                    store.dispatch(.search(text))
                }
                .padding(.horizontal, 16)
                
                SortFilterView(store: store)
                
                if store.isLoading {
                    ProgressView("검색 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.books.isEmpty && !store.query.isEmpty {
                    emptyView
                } else if store.books.isEmpty {
                    Text("검색어를 입력해주세요")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.books, id: \.isbn) { book in
                            BookRowView(
                                book: book,
                                onTap: {
                                    store.dispatch(.navigateToDetail(book))
                                },
                                onLike: {
                                    store.dispatch(.save(book))
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 6, leading: 8, bottom: 6, trailing: 8))
                            .onAppear {
                                if book.isbn == store.books.last?.isbn {
                                    store.dispatch(.loadNextPage)
                                }
                            }
                        }
                        if store.isLoadingMore {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding()
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                    }
                    .scrollDismissesKeyboard(.immediately)
                }
            }
            .ygToolBar {
                YGToolbarItem(placement: .principal) {
                    Text("검색")
                }
            }
        }
    }
    
    private var emptyView: some View {
        VStack {
            Text("검색 결과가 없어요")
            Text("'\(store.query)'의 철자를 확인해주세요.\n긴 문구의 경우 띄어쓰기 해보세요.")
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SearchListView()
}

