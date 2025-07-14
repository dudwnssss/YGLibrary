//
//  BookRepository.swift (Simplified)
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation
import Dependencies
import GRDB

protocol BookRepository {
    func addToFavorites(_ book: Book) async throws
    func removeFromFavorites(uniqueId: String) async throws
    func toggleFavorite(_ book: Book) async throws -> Bool
    func isFavorite(uniqueId: String) async throws -> Bool
    
    func getAllFavoriteBooks() async throws -> [Book]
    func getAllFavoriteUniqueIds() async throws -> Set<String>
}

actor BookRepositoryActor: BookRepository {
    @Dependency(\.databaseService) private var databaseService
    
    init() {}
    
    func addToFavorites(_ book: Book) async throws {
        try await databaseService.write { db in
            var favoriteBook = FavoriteBook(from: book)
            try favoriteBook.insert(db)
        }
    }

    func removeFromFavorites(uniqueId: String) async throws {
        try await databaseService.write { db in
            try db.execute(
                sql: "DELETE FROM favorite_books WHERE uniqueId = ?",
                arguments: [uniqueId]
            )
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        return try await databaseService.write { [weak self] db in
            guard let self = self else { throw DatabaseError.actorDeallocated }
            
            let currentlyFavorite = try checkIsFavorite(uniqueId: book.id, db: db)
            
            if currentlyFavorite {
                try removeFavoriteInTransaction(uniqueId: book.id, db: db)
                return false
            } else {
                try addFavoriteInTransaction(book, db: db)
                return true
            }
        }
    }
    
    func isFavorite(uniqueId: String) async throws -> Bool {
        return try await databaseService.read { [weak self] db in
            guard let self = self else { throw DatabaseError.actorDeallocated }
            return try checkIsFavorite(uniqueId: uniqueId, db: db)
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
    
    func getAllFavoriteUniqueIds() async throws -> Set<String> {
        return try await databaseService.read { db in
            let uniqueIds = try String.fetchAll(
                db,
                sql: "SELECT uniqueId FROM favorite_books"
            )
            return Set(uniqueIds)
        }
    }
}

extension BookRepositoryActor {
    nonisolated private func checkIsFavorite(uniqueId: String, db: Database) throws -> Bool {
        let count = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM favorite_books WHERE uniqueId = ?",
            arguments: [uniqueId]
        ) ?? 0
        return count > 0
    }
    
    nonisolated private func addFavoriteInTransaction(_ book: Book, db: Database) throws {
        var favoriteBook = FavoriteBook(from: book)
        try favoriteBook.insert(db)
    }
    
    nonisolated private func removeFavoriteInTransaction(uniqueId: String, db: Database) throws {
        try db.execute(
            sql: "DELETE FROM favorite_books WHERE uniqueId = ?",
            arguments: [uniqueId]
        )
    }
}


struct BookRepositoryKey: DependencyKey {
    static let liveValue: BookRepository = BookRepositoryActor()
}

extension DependencyValues {
    var bookRepository: BookRepository {
        get { self[BookRepositoryKey.self] }
        set { self[BookRepositoryKey.self] = newValue }
    }
}
