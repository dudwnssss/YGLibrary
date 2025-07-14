//
//  SearchListStore.swift
//  YGLibrary
//
//  Created by 임영준 on 7/12/25.
//

import SwiftUI

import Combine
import Dependencies


final class SearchListStore: Store {
    enum Action {
        case onAppear
        case navigateToDetail(Book)
        case sort(SearchSortType)
        case search(String)
        case loadNextPage
        case toggleFavorite(Book)
        case bookAppeared(Book)
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
        var favoriteUniqueIds: Set<String> = []
        
        private var seenUniqueIds: Set<String> = []
        private var isLoadingNextPage: Bool = false
        private var lastTriggeredUniqueId: String = ""
        
        var hasNextPage: Bool {
            guard let meta else { return false }
            return !meta.isEnd
        }
        
        var canLoadMore: Bool {
            return hasNextPage && !isLoading && !isLoadingMore && !isLoadingNextPage
        }
        
        func isFavorite(_ book: Book) -> Bool {
            return favoriteUniqueIds.contains(book.id)
        }
        
        mutating func addBooksIncremental(_ newBooks: [Book]) {
            var addedBooks: [Book] = []
            
            for book in newBooks {
                if !seenUniqueIds.contains(book.id) {
                    seenUniqueIds.insert(book.id)
                    addedBooks.append(book)
                }
            }
            
            if !addedBooks.isEmpty {
                books.append(contentsOf: addedBooks)
            }
        }
        
        mutating func resetBooks(_ newBooks: [Book]) {
            seenUniqueIds.removeAll()
            books.removeAll()
            lastTriggeredUniqueId = ""
            
            for book in newBooks {
                if !seenUniqueIds.contains(book.id) {
                    seenUniqueIds.insert(book.id)
                    books.append(book)
                }
            }
        }
        
        mutating func setLoadingNextPage(_ loading: Bool) {
            isLoadingNextPage = loading
        }
        
        mutating func checkInfiniteScrollTrigger(for book: Book) -> Bool {
            let booksCount = books.count
            
            guard let bookIndex = books.firstIndex(where: { $0.id == book.id }),
                  bookIndex >= max(0, booksCount - 3),
                  book.id != lastTriggeredUniqueId,
                  canLoadMore else {
                return false
            }
            
            lastTriggeredUniqueId = book.id
            return true
        }
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.bookService) private var service
    @Dependency(\.bookRepository) private var repository
    @Dependency(\.favoriteService) private var favoriteService
    @Dependency(\.toast) private var toast
    
    private var currentSearchTask: Task<Void, Never>?
    private var currentLoadMoreTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setSubscription()
    }
    
    private func setSubscription() {
        favoriteService.favoriteUniqueIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uniqueIds in
                self?.state.favoriteUniqueIds = uniqueIds
            }
            .store(in: &cancellables)
    }
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            Task {
                try await favoriteService.loadFavoriteStatus()
            }
            
        case .navigateToDetail(let book):
            router.navigate(to: .bookDetail(book), type: .push)
            
        case .sort(let sort):
            state.sortType = sort
            if !state.query.isEmpty {
                state.isLoading = true
                resetAndSearch()
            }
            
        case .search(let query):
            state.query = query
            
            if !query.isEmpty {
                state.isLoading = true
                resetAndSearch()
            } else {
                state.resetBooks([])
                state.meta = nil
                state.isLoading = false
            }
            
        case .loadNextPage:
            guard state.canLoadMore, currentLoadMoreTask == nil else { 
                return
            }
            state.setLoadingNextPage(true)
            state.currentPage += 1
            
            currentLoadMoreTask = Task { 
                await loadData(isLoadingMore: true)
                await MainActor.run {
                    state.setLoadingNextPage(false)
                }
                currentLoadMoreTask = nil
            }
        
        case .toggleFavorite(let book):
            Task {
                await toggleFavorite(book)
            }
            
        case .bookAppeared(let book):
            if state.checkInfiniteScrollTrigger(for: book) {
                dispatch(.loadNextPage)
            }
        }
    }
}

extension SearchListStore {
    private func resetAndSearch() {
        currentSearchTask?.cancel()
        currentLoadMoreTask?.cancel()
        currentLoadMoreTask = nil
        
        state.currentPage = 1
        state.meta = nil
        
        currentSearchTask = Task {
            await loadData(isLoadingMore: false)
        }
    }
    
    private func loadData(isLoadingMore: Bool) async {
        guard !state.query.isEmpty else {
            await MainActor.run {
                state.resetBooks([])
                state.meta = nil
            }
            return
        }
        
        await MainActor.run {
            state.isError = false
            if isLoadingMore {
                state.isLoadingMore = true
            }
        }
        
        do {
            let response = try await service.getSearchBook(
                query: state.query,
                sort: state.sortType,
                page: state.currentPage
            )
            
            guard !Task.isCancelled else { 
                return
            }
            
            let newBooks = response.documents.map { Book(from: $0) }
            
            await MainActor.run {
                state.meta = response.meta
                
                if isLoadingMore {
                    let beforeCount = state.books.count
                    state.addBooksIncremental(newBooks)
                    let afterCount = state.books.count
                } else {
                    state.resetBooks(newBooks)
                }
            }
            
        } catch {
            guard !Task.isCancelled else { return }
                        
            await MainActor.run {
                state.isError = true
                
                if isLoadingMore {
                    state.currentPage -= 1
                }
                
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .networkUnavailable, .timeout, .connectionLost:
                        toast.show(.init(message: error.localizedDescription, icon: "info.circle"))
                    default:
                        toast.show(.init(message: "오류가 발생했어요.\n잠시 후 다시 시도해주세요.", icon: "info.circle"))
                    }
                }
            }
        }
        
        await MainActor.run {
            state.isLoading = false
            state.isLoadingMore = false
        }
    }
    
    private func toggleFavorite(_ book: Book) async {
        do {
            let isFavorite = try await favoriteService.toggleFavorite(book)
            
            await MainActor.run {
                if isFavorite {
                    toast.showAddFavorite()
                } else {
                    toast.showRemoveFavorite()
                }
            }
         } catch {
             await MainActor.run {
                 state.isError = true
             }
         }
    }
}
