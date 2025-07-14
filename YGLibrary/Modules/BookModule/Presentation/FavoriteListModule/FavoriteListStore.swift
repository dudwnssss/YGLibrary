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
        var allBooks: [Book] = []
        var books: [Book] = []
        var isLoading: Bool = false
        var isError: Bool = false
        var favoriteUniqueIds: Set<String> = []
        var query: String = ""
        var sortType: FavoriteSortType = .ascending
        var priceFilter: PriceFilter = PriceFilter()
        
        func isFavorite(_ book: Book) -> Bool {
            return favoriteUniqueIds.contains(book.id)
        }
        
        var dynamicPriceRange: (min: Int, max: Int) {
            return PriceFilter.calculatePriceRange(from: allBooks)
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
            if state.allBooks.isEmpty {
                state.isLoading = true
            }
            
            Task {
                await loadInitialData()
            }
            
        case .refresh:
            Task {
                await refreshFromDatabase()
            }
            
        case .navigateToDetail(let book):
            router.navigate(to: .bookDetail(book), type: .push)
            
        case .toggleFavorite(let book):
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
            var updatedFilter = filter
            let currentRange = state.dynamicPriceRange
            updatedFilter.updateDynamicRange(min: currentRange.min, max: currentRange.max)
            state.priceFilter = updatedFilter
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
            try await favoriteService.loadFavoriteStatus()
            
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
                
                let priceRange = state.dynamicPriceRange
                state.priceFilter.updateDynamicRange(min: priceRange.min, max: priceRange.max)
                
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
        do {
            let books = try await repository.getAllFavoriteBooks()
            
            await MainActor.run {
                state.allBooks = books
                
                let priceRange = state.dynamicPriceRange
                state.priceFilter.updateDynamicRange(min: priceRange.min, max: priceRange.max)
                
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
        
        if !state.query.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                book.title.matchesKoreanSearch(state.query) ||
                book.authors.contains { $0.matchesKoreanSearch(state.query) } ||
                book.publisher.matchesKoreanSearch(state.query)
            }
        }
        
        if state.priceFilter.isEnabled {
            filteredBooks = state.priceFilter.apply(to: filteredBooks)
        }
        
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
