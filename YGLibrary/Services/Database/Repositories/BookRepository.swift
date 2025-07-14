//
//  BookRepository.swift (Simplified)
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation
import Dependencies
import GRDB

// MARK: - BookRepository Protocol (Keep for abstraction)
protocol BookRepository {
    func addToFavorites(_ book: Book) async throws
    func removeFromFavorites(isbn: String) async throws
    func toggleFavorite(_ book: Book) async throws -> Bool
    func isFavorite(isbn: String) async throws -> Bool
    
    func getAllFavoriteBooks() async throws -> [Book]
    func getAllFavoriteISBNs() async throws -> Set<String>
}

// MARK: - Actor Implementation (Direct Dependencies Usage)
actor BookRepositoryActor: BookRepository {
    @Dependency(\.databaseService) private var databaseService
    
    init() {}
    
    func addToFavorites(_ book: Book) async throws {
        try await databaseService.write { db in
            var favoriteBook = FavoriteBook(from: book)
            try favoriteBook.insert(db)
        }
    }

    func removeFromFavorites(isbn: String) async throws {
        try await databaseService.write { db in
            try db.execute(
                sql: "DELETE FROM favorite_books WHERE isbn = ?",
                arguments: [isbn]
            )
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        return try await databaseService.write { [weak self] db in
            guard let self = self else { throw DatabaseError.actorDeallocated }
            
            let currentlyFavorite = try checkIsFavorite(isbn: book.isbn, db: db)
            
            if currentlyFavorite {
                try removeFavoriteInTransaction(isbn: book.isbn, db: db)
                return false
            } else {
                try addFavoriteInTransaction(book, db: db)
                return true
            }
        }
    }
    
    func isFavorite(isbn: String) async throws -> Bool {
        return try await databaseService.read { [weak self] db in
            guard let self = self else { throw DatabaseError.actorDeallocated }
            return try checkIsFavorite(isbn: isbn, db: db)
        }
    }

    func getAllFavoriteBooks() async throws -> [Book] {
        return try await databaseService.read { db in
            let entities = try FavoriteBook
                .order(Column("createdAt").desc)
                .fetchAll(db)
            return entities.map { Book(from: $0) }
        }
    }
    
    func getAllFavoriteISBNs() async throws -> Set<String> {
        return try await databaseService.read { db in
            let isbns = try String.fetchAll(
                db,
                sql: "SELECT isbn FROM favorite_books"
            )
            return Set(isbns)
        }
    }
    
    // MARK: - Private Helpers (nonisolated for closures)
    
    nonisolated private func checkIsFavorite(isbn: String, db: Database) throws -> Bool {
        let count = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM favorite_books WHERE isbn = ?",
            arguments: [isbn]
        ) ?? 0
        return count > 0
    }
    
    nonisolated private func addFavoriteInTransaction(_ book: Book, db: Database) throws {
        var favoriteBook = FavoriteBook(from: book)
        try favoriteBook.insert(db)
    }
    
    nonisolated private func removeFavoriteInTransaction(isbn: String, db: Database) throws {
        try db.execute(
            sql: "DELETE FROM favorite_books WHERE isbn = ?",
            arguments: [isbn]
        )
    }
}

// MARK: - Dependencies Integration (Actor directly!)
struct BookRepositoryKey: DependencyKey {
    static let liveValue: BookRepository = BookRepositoryActor()
}

extension DependencyValues {
    var bookRepository: BookRepository {
        get { self[BookRepositoryKey.self] }
        set { self[BookRepositoryKey.self] = newValue }
    }
}
