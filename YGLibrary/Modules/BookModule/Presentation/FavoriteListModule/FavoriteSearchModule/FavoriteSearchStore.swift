//
//  FavoriteSearchStore.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation
import Combine
import Dependencies

struct SearchSuggestion: Identifiable {
    let id: String
    let text: String
    let subtitle: String
    let type: SuggestionType
    let book: Book
}

enum SuggestionType {
    case bookTitle
    case author
    case publisher
    
    var iconName: String {
        switch self {
        case .bookTitle: return "book.closed"
        case .author: return "person"
        case .publisher: return "building.2"
        }
    }
    
    var displayName: String {
        switch self {
        case .bookTitle: return "책 제목"
        case .author: return "저자"
        case .publisher: return "출판사"
        }
    }
}

final class FavoriteSearchStore: Store {
    enum Action {
        case onAppear
        case updateQuery(String)
        case selectSuggestion(SearchSuggestion)
        case selectQuery(String)
    }
    
    struct State {
        var query: String = ""
        var suggestions: [SearchSuggestion] = []
        var favoriteBooks: [Book] = []
        var isLoading: Bool = false
    }
    
    @Published private(set) var state = State()
    @Dependency(\.bookRepository) private var repository
    
    let onQuerySelected: (String) -> Void
    
    init(onQuerySelected: @escaping (String) -> Void) {
        self.onQuerySelected = onQuerySelected
    }
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            Task {
                await loadFavoriteBooks()
            }
            
        case .updateQuery(let query):
            state.query = query
            generateSuggestions()
            
        case .selectSuggestion(let suggestion):
            onQuerySelected(suggestion.text)
            
        case .selectQuery(let query):
            onQuerySelected(query)
        }
    }
}

extension FavoriteSearchStore {
    private func loadFavoriteBooks() async {
        state.isLoading = true
        
        do {
            let books = try await repository.getAllFavoriteBooks()
            await MainActor.run {
                state.favoriteBooks = books
                generateSuggestions()
                state.isLoading = false
            }
        } catch {
            await MainActor.run {
                state.isLoading = false
            }
        }
    }
    
    private func generateSuggestions() {
        guard !state.query.isEmpty else {
            state.suggestions = []
            return
        }
        
        let query = state.query
        var suggestions: [SearchSuggestion] = []
        
        for book in state.favoriteBooks {
            if book.title.matchesKoreanSearch(query) {
                suggestions.append(SearchSuggestion(
                    id: "\(book.isbn)-title",
                    text: book.title,
                    subtitle: book.authors.joined(separator: ", "),
                    type: .bookTitle,
                    book: book
                ))
            }
            
            for author in book.authors {
                if author.matchesKoreanSearch(query) {
                    suggestions.append(SearchSuggestion(
                        id: "\(book.isbn)-author-\(author)",
                        text: author,
                        subtitle: "저자 • \(book.title)",
                        type: .author,
                        book: book
                    ))
                }
            }
            
            if book.publisher.matchesKoreanSearch(query) {
                suggestions.append(SearchSuggestion(
                    id: "\(book.isbn)-publisher",
                    text: book.publisher,
                    subtitle: "출판사 • \(book.title)",
                    type: .publisher,
                    book: book
                ))
            }
        }
        
        let uniqueSuggestions = Array(Set(suggestions.map { $0.text }))
            .compactMap { text in
                suggestions.first { $0.text == text }
            }
            .sorted { lhs, rhs in
                if lhs.type != rhs.type {
                    return lhs.type.sortOrder < rhs.type.sortOrder
                }
                return lhs.text < rhs.text
            }
        
        state.suggestions = Array(uniqueSuggestions.prefix(10))
    }
}

// MARK: - Helper
extension SuggestionType {
    var sortOrder: Int {
        switch self {
        case .bookTitle: return 0
        case .author: return 1
        case .publisher: return 2
        }
    }
}
