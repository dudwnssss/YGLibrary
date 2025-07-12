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
                SearchBarView()
                    .padding(.horizontal, 16)
                SortFilterView(store: store)
                List(store.data?.documents ?? []) { book in
                    BookRowView(book: book) {
                        store.dispatch(.navigateToDetail(book))
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
            }
            .ygToolBar {
                YGToolbarItem(placement: .principal) {
                    Text("검색")
                }
            }
            .onAppear {
                store.dispatch(.onAppear)
            }
        }
    }
}

#Preview {
    SearchListView()
}

