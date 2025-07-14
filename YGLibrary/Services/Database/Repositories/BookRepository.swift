//
//  BookRepository.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

import Dependencies
import GRDB

protocol BookRepository {
    func addToFavorites(_ book: Book) async throws
    func removeFromFavorites(isbn: String) async throws
    func toggleFavorite(_ book: Book) async throws -> Bool
    func isFavorite(isbn: String) async throws -> Bool
    
    func getAllFavoriteBooks() async throws -> [Book]
    func getAllFavoriteISBNs() async throws -> Set<String>
}

final class BookRepositoryImpl: BookRepository {
    @Dependency(\.databaseService) private var service
    static let shared = BookRepositoryImpl()
    private init() {}
    
    func addToFavorites(_ book: Book) async throws {
        try await withCheckedThrowingContinuation { continuation in
            do {
                try service.write { db in
                    var favoriteBook = FavoriteBook(from: book)
                    try favoriteBook.insert(db)
                }
                continuation.resume()
            } catch {
                continuation.resume(throwing: error)
            }
            
        }
    }

    func removeFromFavorites(isbn: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
             do {
                 try service.write { db in
                     try db.execute(
                         sql: "DELETE FROM favorite_books WHERE isbn = ?",
                         arguments: [isbn]
                     )
                 }
                 continuation.resume()
             } catch {
                 continuation.resume(throwing: error)
             }
         }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let result = try service.write { db in
                    if try self.isFavorite(isbn: book.isbn, db: db) {
                        try self.removeFavorite(isbn: book.isbn, db: db)
                        return false // 제거됨
                    } else {
                        try self.addFavorite(book, db: db)
                        return true // 추가됨
                    }
                }
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func isFavorite(isbn: String) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let result = try service.read { db in
                    try self.isFavorite(isbn: isbn, db: db)
                }
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }


    func getAllFavoriteBooks() async throws -> [Book] {
        return try await withCheckedThrowingContinuation { continuation in
             do {
                 let result = try service.read { db in
                     let entities = try FavoriteBook
                         .order(Column("createdAt").desc)
                         .fetchAll(db)
                     return entities.map { Book(from: $0) }
                 }
                 continuation.resume(returning: result)
             } catch {
                 continuation.resume(throwing: error)
             }
         }
    }
    
    func getAllFavoriteISBNs() async throws -> Set<String> {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let result = try service.read { db in
                    let isbns = try String.fetchAll(
                        db,
                        sql: "SELECT isbn FROM favorite_books"
                    )
                    return Set(isbns)
                }
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

extension BookRepositoryImpl {
    private func isFavorite(isbn: String, db: Database) throws -> Bool {
        let count = try Int.fetchOne(
            db,
            sql: "SELECT COUNT(*) FROM favorite_books WHERE isbn = ?",
            arguments: [isbn]
        ) ?? 0
        return count > 0
    }
    
    private func addFavorite(_ book: Book, db: Database) throws {
        var favoriteBook = FavoriteBook(from: book)
        try favoriteBook.insert(db)
    }
    
    private func removeFavorite(isbn: String, db: Database) throws {
        try db.execute(
            sql: "DELETE FROM favorite_books WHERE isbn = ?",
            arguments: [isbn]
        )
    }
}

import Dependencies

struct BookRepositoryKey: DependencyKey {
    static let liveValue: BookRepository = BookRepositoryImpl.shared
}

extension DependencyValues {
    var bookRepository: BookRepository {
        get { self[BookRepositoryKey.self] }
        set { self[BookRepositoryKey.self] = newValue }
    }
}
