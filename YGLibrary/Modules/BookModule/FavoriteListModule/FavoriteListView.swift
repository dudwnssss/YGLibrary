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
    }

    struct State {
        var books: [Book] = []
        var isLoading: Bool = false
        var isError: Bool = false
        var favoriteISBNs: Set<String> = []
        
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
                state.books = books
                state.isLoading = false
                
                print("📋 최종 상태:")
                print("   - state.books 개수: \(state.books.count)")
                print("   - state.favoriteISBNs 개수: \(state.favoriteISBNs.count)")
                print("   - state.favoriteISBNs: \(state.favoriteISBNs)")
            }
        } catch {
            print("❌ loadFavoriteBooks 실패: \(error)")
            await MainActor.run {
                state.isError = true
                state.isLoading = false
            }
        }
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
        }
    }
}


struct FavoriteListView: View {
    @StateObject var store = FavoriteListStore()
    
    var body: some View {
        VStack {
            if store.state.isLoading {
                ProgressView("로딩 중...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if store.state.books.isEmpty {
                emptyView
            } else {
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
                        .onAppear {
                            // 🔍 각 BookRowView의 상태 디버깅
                            print("📱 BookRowView for \(book.title):")
                            print("   - ISBN: \(book.isbn)")
                            print("   - isFavorite: \(store.state.isFavorite(book))")
                            print("   - favoriteISBNs contains: \(store.state.favoriteISBNs.contains(book.isbn))")
                        }
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(.init(top: 6, leading: 8, bottom: 6, trailing: 8))
                    }
                }
                .refreshable {
//                    store.dispatch(.refresh)
                }
            }
        }
        .onAppear {
            store.dispatch(.onAppear)
        }
        .ygToolbar {
            YGToolbarItem.principal {
                Text("즐겨찾기")
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("즐겨찾기한 책이 없습니다")
                .font(.headline)
                .foregroundColor(.gray)
            
            Text("검색에서 마음에 드는 책을\n즐겨찾기에 추가해보세요")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}