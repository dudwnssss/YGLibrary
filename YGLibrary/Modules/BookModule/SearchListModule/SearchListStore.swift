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
        case bookAppeared(Book) // 새로운 액션 추가
    }
    
    struct State {
        var books: [Book] = []             // 최종 표시될 책 목록 (중복 제거됨)
        var meta: MetaResponse<BookDTO>.Meta?
        var sortType: SearchSortType = .accuracy
        var isLoading: Bool = false
        var isLoadingMore: Bool = false
        var isError: Bool = false
        var query: String = ""
        var currentPage: Int = 1
        var favoriteISBNs: Set<String> = []
        
        // 내부 상태 (UI에 영향 주지 않음)
        private var seenISBNs: Set<String> = []
        private var isLoadingNextPage: Bool = false // 중복 로딩 방지
        private var lastTriggeredISBN: String = "" // 무한스크롤 중복 방지
        
        var hasNextPage: Bool {
            guard let meta else { return false }
            return !meta.isEnd
        }
        
        var canLoadMore: Bool {
            return hasNextPage && !isLoading && !isLoadingMore && !isLoadingNextPage
        }
        
        func isFavorite(_ book: Book) -> Bool {
            return favoriteISBNs.contains(book.isbn)
        }
        
        // 성능 최적화: 증분 업데이트
        mutating func addBooksIncremental(_ newBooks: [Book]) {
            var addedBooks: [Book] = []
            
            for book in newBooks {
                if !seenISBNs.contains(book.isbn) {
                    seenISBNs.insert(book.isbn)
                    addedBooks.append(book)
                }
            }
            
            if !addedBooks.isEmpty {
                books.append(contentsOf: addedBooks)
            }
        }
        
        mutating func resetBooks(_ newBooks: [Book]) {
            seenISBNs.removeAll()
            books.removeAll()
            lastTriggeredISBN = "" // 무한스크롤 상태 초기화
            
            for book in newBooks {
                if !seenISBNs.contains(book.isbn) {
                    seenISBNs.insert(book.isbn)
                    books.append(book)
                }
            }
        }
        
        mutating func setLoadingNextPage(_ loading: Bool) {
            isLoadingNextPage = loading
        }
        
        // 무한스크롤 트리거 로직
        mutating func checkInfiniteScrollTrigger(for book: Book) -> Bool {
            let booksCount = books.count
            
            guard let bookIndex = books.firstIndex(where: { $0.isbn == book.isbn }),
                  bookIndex >= max(0, booksCount - 3),
                  book.isbn != lastTriggeredISBN,
                  canLoadMore else {
                return false
            }
            
            lastTriggeredISBN = book.isbn
            return true
        }
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.bookService) private var service
    @Dependency(\.bookRepository) private var repository
    @Dependency(\.favoriteService) private var favoriteService
    @Dependency(\.toast) private var toast
    
    // MARK: - Task Management
    private var currentSearchTask: Task<Void, Never>?
    private var currentLoadMoreTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // 호환성을 위한 computed properties
    var query: String { state.query }
    var sortType: SearchSortType { state.sortType }
    var isLoading: Bool { state.isLoading }
    var isLoadingMore: Bool { state.isLoadingMore }
    
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
            // 🎯 중복 로딩 방지 최적화
            print("📱 LoadNextPage called - canLoadMore: \(state.canLoadMore), currentTask: \(currentLoadMoreTask != nil)")
            
            guard state.canLoadMore, currentLoadMoreTask == nil else { 
                print("⏹️ LoadNextPage blocked - canLoadMore: \(state.canLoadMore), hasTask: \(currentLoadMoreTask != nil)")
                return 
            }
            
            print("🚀 Starting loadNextPage - page: \(state.currentPage + 1)")
            
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
            // 무한스크롤 로직을 Store에서 처리
            if state.checkInfiniteScrollTrigger(for: book) {
                print("🚀 Infinite scroll triggered at book: \(book.title), ISBN: \(book.isbn)")
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
        print("🌐 LoadData started - isLoadingMore: \(isLoadingMore), page: \(state.currentPage), query: '\(state.query)'")
        
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
                print("🔄 Set isLoadingMore = true")
            }
        }
        
        do {
            let response = try await service.getSearchBook(
                query: state.query,
                sort: state.sortType,
                page: state.currentPage
            )
            
            guard !Task.isCancelled else { 
                print("❌ Task cancelled")
                return 
            }
            
            let newBooks = response.documents.map { Book(from: $0) }
            print("📚 Received \(newBooks.count) books, meta.isEnd: \(response.meta.isEnd)")
            
            await MainActor.run {
                state.meta = response.meta
                
                if isLoadingMore {
                    // 🚀 성능 최적화: 증분 업데이트로 깜빡임 방지
                    let beforeCount = state.books.count
                    state.addBooksIncremental(newBooks)
                    let afterCount = state.books.count
                    print("➕ Books added: \(beforeCount) -> \(afterCount) (+\(afterCount - beforeCount))")
                } else {
                    // 🔄 새 검색: 전체 초기화
                    state.resetBooks(newBooks)
                    print("🆕 Books reset: \(newBooks.count) books")
                }
            }
            
        } catch {
            guard !Task.isCancelled else { return }
            
            print("❌ LoadData error: \(error)")
            
            await MainActor.run {
                state.isError = true
                
                if isLoadingMore {
                    state.currentPage -= 1
                    print("⬅️ Page rolled back to: \(state.currentPage)")
                }
                
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .networkUnavailable, .timeout, .connectionLost:
                        toast.show(.init(message: error.localizedDescription, icon: "info.circle"))
                    default:
                        break
                    }
                }
            }
        }
        
        await MainActor.run {
            state.isLoading = false
            state.isLoadingMore = false
            print("✅ LoadData completed - isLoading: false, isLoadingMore: false")
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
                 print("즐겨찾기 처리 중 오류가 발생했습니다: \(error)")
             }
         }
    }
}
