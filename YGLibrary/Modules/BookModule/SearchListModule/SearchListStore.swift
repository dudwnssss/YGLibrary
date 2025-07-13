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
        var favoriteISBNs: Set<String> = []
        
        var hasNextPage: Bool {
            guard let meta else { return false }
            return !meta.isEnd
        }
        
        var canLoadMore: Bool {
            return hasNextPage && !isLoading && !isLoadingMore
        }
        
        func isFavorite(_ book: Book) -> Bool {
            return favoriteISBNs.contains(book.isbn)
        }
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.bookService) private var service
    @Dependency(\.bookRepository) private var repository
    @Dependency(\.favoriteService) private var favoriteService
    
    private var currentSearchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setSubscription()
    }
    
    private func setSubscription() {
        favoriteService.favoriteISBNs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isbns in
                self?.state.favoriteISBNs = isbns
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
                resetAndSearch()
            }
            
        case .search(let query):
            state.query = query
            resetAndSearch()
            
        case .loadNextPage:
            guard state.canLoadMore else { return }
            state.currentPage += 1
            Task { await loadData(isLoadingMore: true) }
        
        case .toggleFavorite(let book):
            Task {
                await toggleFavorite(book)
            }
        }
    }
}

extension SearchListStore {
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
            
            await loadFavoriteStatus()
            
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
    
    private func toggleFavorite(_ book: Book) async {
        do {
            let isFavorite = try await favoriteService.toggleFavorite(book)
            if isFavorite {
                print("'\(book.title)' 즐겨찾기에 추가되었습니다")
            } else {
                print("'\(book.title)' 즐겨찾기에서 제거되었습니다")
            }
         } catch {
             await MainActor.run {
                 state.isError = true
                 print("즐겨찾기 처리 중 오류가 발생했습니다: \(error)")
             }
         }
    }
    
    private func loadFavoriteStatus() async {
        do {
            let favoriteISBNs = try await repository.getAllFavoriteISBNs()
            state.favoriteISBNs  = favoriteISBNs
        } catch {
            print("즐겨찾기 상태 로드 실패: \(error)")
        }
    }
}
