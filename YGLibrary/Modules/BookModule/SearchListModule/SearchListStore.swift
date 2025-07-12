//
//  SearchListStore.swift
//  YGLibrary
//
//  Created by 임영준 on 7/12/25.
//

import SwiftUI

import Dependencies


final class SearchListStore: Store {
    enum Action {
        case onAppear
        case navigateToDetail(Book)
        case sort(SearchSortType)
    }
    
    struct State {
        var data: MetaResponse<Book>?
        var sortType: SearchSortType = .accuracy
        var isLoading: Bool = false
        var isError: Bool = false
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.bookService) private var service
     
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            Task { await loadData() }
        case .navigateToDetail(let book):
            router.navigate(to: .bookDetail(book), type: .push)
        case .sort(let sort):
            state.sortType = sort
            Task { await loadData() }
        }
    }
    
    private func loadData() async {
        state.isError = false
        state.isLoading = true
        do {
            let data = try await service.getSearchBook(
                query: "안녕",
                sort: state.sortType,
                page: nil
            )
            state.data = data
        } catch {
            state.isError = true
        }
        state.isLoading = false
    }
}
