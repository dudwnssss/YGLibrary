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
        case navigateToDetail(Book)
        case removeFavorite(Book)
        case search(String)
        case sort(FavoriteSortType)
        case updatePriceFilter(PriceFilter)
        case openSearchModal
    }
    
    struct State {
        var allBooks: [Book] = []           // 전체 즐겨찾기 책들
        var books: [Book] = []              // 검색/정렬 결과
        var isLoading: Bool = false
        var isError: Bool = false
        var favoriteISBNs: Set<String> = []
        var query: String = ""              // 검색어
        var sortType: FavoriteSortType = .ascending // 정렬 타입
        var priceFilter: PriceFilter = PriceFilter() // 가격 필터
        
        func isFavorite(_ book: Book) -> Bool {
            return favoriteISBNs.contains(book.isbn)
        }
    }
    
    @Published private(set) var state = State()
    @Dependency(\.router) private var router
    @Dependency(\.favoriteService) private var favoriteService
    @Dependency(\.bookRepository) private var repository
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        print("🏪 FavoriteListStore 초기화")
        setSubscription()
    }
    
    private func setSubscription() {
        print("🔗 setSubscription 시작")
        
        favoriteService.favoriteISBNs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isbns in
                print("📥 favoriteService.favoriteISBNs 업데이트:")
                print("   - 받은 isbns 개수: \(isbns.count)")
                print("   - 받은 isbns 내용: \(isbns)")
                
                self?.state.favoriteISBNs = isbns
                print("   - state.favoriteISBNs 업데이트됨: \(self?.state.favoriteISBNs ?? [])")
                
                Task {
                    await self?.loadFavoriteBooks()
                }
            }
            .store(in: &cancellables)
        
        print("✅ setSubscription 완료")
    }
    
    private func loadFavoriteBooks() async {
        print("📚 loadFavoriteBooks 시작")
        
        do {
            state.isLoading = true
            let books = try await repository.getAllFavoriteBooks()
            
            print("📖 repository에서 가져온 책들:")
            print("   - 개수: \(books.count)")
            books.forEach { print("   - \($0.title) (ISBN: \($0.isbn))") }
            
            await MainActor.run {
                state.allBooks = books
                filterAndSortBooks()
                state.isLoading = false
                
                print("📋 최종 상태:")
                print("   - state.allBooks 개수: \(state.allBooks.count)")
                print("   - state.books 개수: \(state.books.count)")
                print("   - state.favoriteISBNs 개수: \(state.favoriteISBNs.count)")
            }
        } catch {
            print("❌ loadFavoriteBooks 실패: \(error)")
            await MainActor.run {
                state.isError = true
                state.isLoading = false
            }
        }
    }
    
    // MARK: - 검색 및 정렬 로직
    private func filterAndSortBooks() {
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
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            print("👁️ FavoriteListView onAppear")
            Task {
                try await favoriteService.loadFavoriteStatus()
                await loadFavoriteBooks()
            }
            
        case .navigateToDetail(let book):
            router.navigate(to: .bookDetail(book), type: .push)
            
        case .removeFavorite(let book):
            print("💔 removeFavorite: \(book.title)")
            Task {
                do {
                    _ = try await favoriteService.toggleFavorite(book)
                    print("✅ '\(book.title)' 즐겨찾기에서 제거됨")
                } catch {
                    print("❌ removeFavorite 실패: \(error)")
                    await MainActor.run {
                        state.isError = true
                    }
                }
            }
            
        case .search(let query):
            print("🔍 검색어 변경: '\(query)'")
            state.query = query
            filterAndSortBooks()
            
        case .sort(let sortType):
            print("🔄 정렬 변경: \(sortType.displayText)")
            state.sortType = sortType
            filterAndSortBooks()
            
        case .updatePriceFilter(let filter):
            print("💰 가격 필터 변경: \(filter.displayText)")
            state.priceFilter = filter
            filterAndSortBooks()
            
        case .openSearchModal:
            print("🔍 검색 모달 열기")
            router.navigate(to: .favoriteSearchModal { [weak self] query in
                self?.dispatch(.search(query))
            }, type: .present())
        }
    }
}
