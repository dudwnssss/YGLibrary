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
        var allBooks: [Book] = []          // 중복 제거 전 원본 데이터
        var books: [Book] = []             // 화면에 표시될 최종 데이터 (중복 제거 + 정렬 적용)
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
    @Dependency(\.toast) private var toast
    
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
            
            // 검색어가 있을 때만 로딩 상태 처리
            if !query.isEmpty {
                // 기존 데이터가 있으면 오버레이 로딩, 없으면 전체 화면 로딩
                state.isLoading = true
                resetAndSearch()
            } else {
                // 검색어가 비어있으면 결과 초기화
                state.allBooks = []
                state.books = []
                state.meta = nil
                state.isLoading = false
            }
            
        case .loadNextPage:
            // 이미 로딩 중이거나 더 이상 데이터가 없으면 중단
            guard state.canLoadMore, currentLoadMoreTask == nil else { return }
            
            state.currentPage += 1
            currentLoadMoreTask = Task { 
                await loadData(isLoadingMore: true)
                currentLoadMoreTask = nil
            }
        
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
        currentLoadMoreTask?.cancel() // 로드더 태스크도 취소
        currentLoadMoreTask = nil
        
        state.currentPage = 1
        state.allBooks = []
        // 기존 books는 유지해서 UI 깜뿍임 방지 (새로운 데이터 로드 시 업데이트)
        state.meta = nil
        
        currentSearchTask = Task {
            await loadData(isLoadingMore: false)
        }
    }
    
    private func loadData(isLoadingMore: Bool) async {
        guard !state.query.isEmpty else {
            state.allBooks = []
            state.books = []
            state.meta = nil
            return
        }
        
        state.isError = false
        
        if isLoadingMore {
            state.isLoadingMore = true
        }
        // 이미 search 액션에서 isLoading을 설정했으므로 여기서는 설정하지 않음
        
        do {
            let response = try await service.getSearchBook(
                query: state.query,
                sort: state.sortType,
                page: state.currentPage
            )
            
            guard !Task.isCancelled else { return }
            
            state.meta = response.meta
            
            if isLoadingMore {
                let newBooks = response.documents.map { Book(from: $0) }
                state.allBooks.append(contentsOf: newBooks)
            } else {
                state.allBooks = response.documents.map { Book(from: $0) }
            }
            
            // 중복 제거 및 정렬 적용
            applyUniqueAndSort()
            
            await loadFavoriteStatus()
            
        } catch {
            guard !Task.isCancelled else { return }
            state.isError = true
            
            if isLoadingMore {
                state.currentPage -= 1
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
        
        state.isLoading = false
        state.isLoadingMore = false
    }
    
    // 🎯 중복 제거 및 정렬 적용
    private func applyUniqueAndSort() {
        var seenISBNs: Set<String> = []
        let uniqueBooks = state.allBooks.filter { book in
            if seenISBNs.contains(book.isbn) {
                return false
            } else {
                seenISBNs.insert(book.isbn)
                return true
            }
        }
        
        state.books = uniqueBooks
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
    
    private func loadFavoriteStatus() async {
        do {
            let favoriteISBNs = try await repository.getAllFavoriteISBNs()
            state.favoriteISBNs  = favoriteISBNs
        } catch {
            print("즐겨찾기 상태 로드 실패: \(error)")
        }
    }
}
