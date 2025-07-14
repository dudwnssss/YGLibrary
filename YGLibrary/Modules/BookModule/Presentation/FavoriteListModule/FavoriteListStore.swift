//
//  FavoriteListStore.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

import Combine
import Dependencies

final class FavoriteListStore: Store {
    enum Action {
        case onAppear
        case refresh
        case navigateToDetail(Book)
        case toggleFavorite(Book)
        case search(String)
        case sort(FavoriteSortType)
        case updatePriceFilter(PriceFilter)
        case openSearchModal
    }
    
    struct State {
        var allBooks: [Book] = []           // 전체 즐겨찾기 책들
        var books: [Book] = []              // 필터링/정렬된 결과
        var isLoading: Bool = false
        var isError: Bool = false
        var favoriteUniqueIds: Set<String> = []
        var query: String = ""              // 검색어
        var sortType: FavoriteSortType = .ascending // 정렬 타입
        var priceFilter: PriceFilter = PriceFilter() // 가격 필터
        
        func isFavorite(_ book: Book) -> Bool {
            return favoriteUniqueIds.contains(book.id)
        }
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.favoriteService) private var favoriteService
    @Dependency(\.bookRepository) private var repository
    @Dependency(\.toast) private var toast
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setSubscription()
    }
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            // 최초 로딩시에만 로딩 상태 표시
            if state.allBooks.isEmpty {
                state.isLoading = true
            }
            
            Task {
                await loadInitialData()
            }
            
        case .refresh:
            // 🎯 새로고침 시에만 실제 즐겨찾기 상태 반영
            Task {
                await refreshFromDatabase()
            }
            
        case .navigateToDetail(let book):
            router.navigate(to: .bookDetail(book), type: .push)
            
        case .toggleFavorite(let book):
            // Actor handles concurrency automatically
            Task {
                await toggleFavorite(book)
            }
            
        case .search(let query):
            state.query = query
            applyFiltersAndSort()
            
        case .sort(let sortType):
            state.sortType = sortType
            applyFiltersAndSort()
            
        case .updatePriceFilter(let filter):
            state.priceFilter = filter
            applyFiltersAndSort()
            
        case .openSearchModal:
            router.navigate(to: .favoriteSearchModal { [weak self] query in
                self?.dispatch(.search(query))
            }, type: .present())
        }
    }
}

extension FavoriteListStore {
    private func setSubscription() {
        favoriteService.favoriteUniqueIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] uniqueIds in
                self?.state.favoriteUniqueIds = uniqueIds
            }
            .store(in: &cancellables)
    }
    
    private func loadInitialData() async {
        do {
            // 1. 즐겨찾기 상태 로드
            try await favoriteService.loadFavoriteStatus()
            
            // 2. 즐겨찾기 책들 로드 (DB에서 실제 데이터)
            await loadFavoriteBooksFromDatabase()
            
        } catch {
            await MainActor.run {
                state.isError = true
                state.isLoading = false
            }
        }
    }
    
    private func loadFavoriteBooksFromDatabase() async {
        do {
            let books = try await repository.getAllFavoriteBooks()
            
            await MainActor.run {
                state.allBooks = books
                applyFiltersAndSort()
                state.isLoading = false
                state.isError = false
            }
        } catch {
            await MainActor.run {
                state.isError = true
                state.isLoading = false
            }
        }
    }
    
    private func refreshFromDatabase() async {
        // 새로고침 시에만 DB에서 최신 데이터 가져와서 UI 업데이트
        do {
            let books = try await repository.getAllFavoriteBooks()
            
            await MainActor.run {
                state.allBooks = books
                applyFiltersAndSort()
                state.isError = false
            }
        } catch {
            await MainActor.run {
                state.isError = true
            }
        }
    }
    
    private func applyFiltersAndSort() {
        var filteredBooks = state.allBooks
        
        // 검색 필터링 (초성 포함)
        if !state.query.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                book.title.matchesKoreanSearch(state.query) ||
                book.authors.contains { $0.matchesKoreanSearch(state.query) } ||
                book.publisher.matchesKoreanSearch(state.query)
            }
        }
        
        // 가격 필터링
        if state.priceFilter.isEnabled {
            filteredBooks = filteredBooks.filter { book in
                let price = book.pricing.salePrice > 0 ? book.pricing.salePrice : book.pricing.originPrice
                return price >= state.priceFilter.minPrice && price <= state.priceFilter.maxPrice
            }
        }
        
        // 정렬
        switch state.sortType {
        case .ascending:
            filteredBooks = filteredBooks.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        case .descending:
            filteredBooks = filteredBooks.sorted {
                $0.title.localizedStandardCompare($1.title) == .orderedDescending
            }
        }
        
        state.books = filteredBooks
    }
    
    private func toggleFavorite(_ book: Book) async {
        do {
            let isFavorite = try await favoriteService.toggleFavorite(book)
            
            await MainActor.run {
                if isFavorite {
                    toast.showAddFavorite()
                    // 새로 추가된 경우에만 즉시 UI에 추가
                    if !state.allBooks.contains(where: { $0.id == book.id }) {
                        state.allBooks.append(book)
                        applyFiltersAndSort()
                    }
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
