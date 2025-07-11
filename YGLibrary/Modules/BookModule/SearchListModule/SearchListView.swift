//
//  SearchListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

import Dependencies

struct SearchListView: View {
    @Dependency(\.bookService) private var service
    @Dependency(\.router) private var router
    @State private var data: BaseResponse<Book>?
    
    var body: some View {
        YGNavigationView {
            VStack {
                SearchBarView()
                    .padding(.horizontal, 16)
                SortFilterView()
                List(data?.documents ?? []) { book in
                    BookRowView(book: book) {
                        router.navigate(to: .bookDetail(book), type: .push)
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
        }
        .task {
            do {
                let data = try await service.getSearchBook(
                    query: "안녕",
                    sort: .latest,
                    page: nil
                )
                self.data = data
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    SearchListView()
}

