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
                
                if store.state.isLoading {
                    ProgressView("검색 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.state.books.isEmpty && !store.state.query.isEmpty {
                    Text("검색 결과가 없어요")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if store.state.books.isEmpty {
                    Text("검색어를 입력해주세요")
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(store.state.books, id: \.isbn) { book in
                            BookRowView(book: book) {
                                store.dispatch(.navigateToDetail(book))
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 6, leading: 8, bottom: 6, trailing: 8))
                            .onAppear {
                                // 마지막 아이템에 도달하면 다음 페이지 로드
                                if book.isbn == store.state.books.last?.isbn {
                                    store.dispatch(.loadNextPage)
                                }
                            }
                        }
                        
                        // 로딩 인디케이터
                        if store.state.isLoadingMore {
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
}

#Preview {
    SearchListView()
}

