//
//  FavoriteListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI
import Combine
import Dependencies

final class FavoriteListStore: Store {
    enum Action {
        case onAppear
        case navigateToDetail(Book)
        case removeFavorite(Book)
        case search(String)
        case sort(FavoriteSortType)
    }

    struct State {
        var allBooks: [Book] = []           // 전체 즐겨찾기 책들
        var books: [Book] = []              // 검색/정렬 결과
        var isLoading: Bool = false
        var isError: Bool = false
        var favoriteISBNs: Set<String> = []
        var query: String = ""              // 검색어
        var sortType: FavoriteSortType = .ascending // 정렬 타입
        
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
        
        // 검색 필터링
        if !state.query.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                book.title.localizedCaseInsensitiveContains(state.query) ||
                book.authors.joined(separator: " ").localizedCaseInsensitiveContains(state.query) ||
                book.publisher.localizedCaseInsensitiveContains(state.query)
            }
        }
        
        // 정렬
        switch state.sortType {
        case .ascending:
            filteredBooks = filteredBooks.sorted { $0.title < $1.title }
        case .descending:
            filteredBooks = filteredBooks.sorted { $0.title > $1.title }
        }
        
        state.books = filteredBooks
        
        print("🔍 검색/정렬 결과:")
        print("   - 검색어: '\(state.query)'")
        print("   - 정렬: \(state.sortType.displayText)")
        print("   - 결과 개수: \(state.books.count)")
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
        }
    }
}

struct FavoriteListView: View {
    @StateObject var store = FavoriteListStore()
    
    var body: some View {
        VStack(spacing: 0) {
            // 검색바 (SearchListView와 동일한 패턴)
            SearchBarView(query: store.state.query) { text in
                store.dispatch(.search(text))
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // 정렬/필터 (즐겨찾기 데이터가 있을 때만 표시)
            if !store.state.allBooks.isEmpty {
                FavoriteSortFilterView(store: store)
            }
            
            // 메인 콘텐츠
            Group {
                if store.state.isLoading {
                    // 로딩 상태
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("즐겨찾기 불러오는 중...")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if store.state.allBooks.isEmpty {
                    // 즐겨찾기가 전혀 없는 상태
                    emptyFavoritesView
                    
                } else if store.state.books.isEmpty && !store.state.query.isEmpty {
                    // 검색 결과 없음
                    emptySearchView
                    
                } else {
                    // 즐겨찾기 리스트
                    List {
                        ForEach(store.state.books, id: \.isbn) { book in
                            BookRowView(
                                book: book,
                                isFavorite: store.state.isFavorite(book),
                                onTap: {
                                    store.dispatch(.navigateToDetail(book))
                                },
                                onFavoriteToggle: {
                                    store.dispatch(.removeFavorite(book))
                                }
                            )
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        store.dispatch(.onAppear)
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            store.dispatch(.onAppear)
        }
        .ygToolbar {
            YGToolbarItem.principal {
                Text("즐겨찾기")
                    .font(.system(size: 18, weight: .semibold))
            }
        }
    }
    
    // MARK: - Subviews
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("즐겨찾기한 책이 없습니다")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("검색에서 마음에 드는 책을\n즐겨찾기에 추가해보세요")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptySearchView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("검색 결과가 없어요")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("'\(store.state.query)'와 일치하는\n즐겨찾기 책이 없습니다")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
