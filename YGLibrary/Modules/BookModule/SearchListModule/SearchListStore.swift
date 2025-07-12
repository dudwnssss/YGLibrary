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
        case search(String)
        case loadNextPage
        case save(Book)
    }
    
    struct State {
        var books: [Book] = []
        var meta: MetaResponse<BookDTO>.Meta?
        var sortType: SearchSortType = .accuracy
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var isError: Bool = false
        var query: String = ""
        var currentPage: Int = 1
        
        var hasNextPage: Bool {
            guard let meta else { return false }
            return !meta.isEnd
        }
        
        var canLoadMore: Bool {
            return hasNextPage && !isLoading && !isLoadingMore
        }
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.bookService) private var service
    
    private var currentSearchTask: Task<Void, Never>?
     
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            break
            
        case .navigateToDetail(let book):
            router.navigate(to: .bookDetail(book), type: .push)
            
        case .sort(let sort):
            state.sortType = sort
            if !state.query.isEmpty {
                resetAndSearch()
            }
            
        case .search(let query):
            state.query = query
            resetAndSearch()
            
        case .loadNextPage:
            guard state.canLoadMore else { return }
            state.currentPage += 1
            Task { await loadData(isLoadingMore: true) }
        
        case .save(let book):
            print(book)
        }
    }
    
    private func resetAndSearch() {
        currentSearchTask?.cancel()
        state.currentPage = 1
        state.books = []
        state.meta = nil
        
        currentSearchTask = Task {
            await loadData(isLoadingMore: false)
        }
    }
    
    private func loadData(isLoadingMore: Bool) async {
        guard !state.query.isEmpty else {
            state.books = []
            state.meta = nil
            return
        }
        
        state.isError = false
        
        if isLoadingMore {
            state.isLoadingMore = true
        } else {
            state.isLoading = true
        }
        
        do {
            let response = try await service.getSearchBook(
                query: state.query,
                sort: state.sortType,
                page: state.currentPage
            )
            
            guard !Task.isCancelled else { return }
            
            state.meta = response.meta
            
            if isLoadingMore {
                state.books.append(contentsOf: response.documents.map { Book(from: $0) })
            } else {
                state.books = response.documents.map { Book(from: $0) }
            }
            
        } catch {
            guard !Task.isCancelled else { return }
            state.isError = true
            
            if isLoadingMore {
                state.currentPage -= 1
            }
        }
        
        state.isLoading = false
        state.isLoadingMore = false
    }
}
