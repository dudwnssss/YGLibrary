//
//  DatabaseService.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import Foundation

import GRDB
import Dependencies

enum DatabaseError: Error, LocalizedError {
    case actorDeallocated
    case initializationFailed(String)
    case operationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .actorDeallocated:
            return "Database actor was deallocated during operation"
        case .initializationFailed(let message):
            return "Database initialization failed: \(message)"
        case .operationFailed(let message):
            return "Database operation failed: \(message)"
        }
    }
}

actor DatabaseService {
    private let dbQueue: DatabaseQueue
    
    init() throws {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let databasePath = "\(documentsPath)/YGLibrary.sqlite"
        
        do {
            dbQueue = try DatabaseQueue(path: databasePath)
            try Self.createTables(in: dbQueue)
        } catch {
            throw DatabaseError.initializationFailed(error.localizedDescription)
        }
    }
    
    func write<T: Sendable>(_ updates: @Sendable @escaping (Database) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let result = try dbQueue.write(updates)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    func read<T: Sendable>(_ value: @Sendable @escaping (Database) throws -> T) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                let result = try dbQueue.read(value)
                continuation.resume(returning: result)
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

extension DatabaseService {
    nonisolated private static func createTables(in dbQueue: DatabaseQueue) throws {
        try dbQueue.write { db in
            try db.create(table: "favorite_books", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("uniqueId", .text).notNull().unique(onConflict: .replace)
                t.column("isbn", .text).notNull()
                t.column("title", .text).notNull()
                t.column("authors", .blob).notNull()
                t.column("publisher", .text).notNull()
                t.column("translators", .blob).notNull()
                t.column("thumbnail", .text)
                t.column("price", .integer).notNull()
                t.column("salePrice", .integer).notNull()
                t.column("status", .text).notNull()
                t.column("url", .text)
                t.column("contents", .text).notNull()
                t.column("dateTime", .datetime)
                t.column("createdAt", .datetime).notNull()
            }
            
            // Create indexes for better performance
            try db.create(index: "idx_uniqueId", on: "favorite_books", columns: ["uniqueId"], ifNotExists: true)
            try db.create(index: "idx_isbn", on: "favorite_books", columns: ["isbn"], ifNotExists: true)
            try db.create(index: "idx_title", on: "favorite_books", columns: ["title"], ifNotExists: true)
        }
    }
}

struct DatabaseServiceKey: DependencyKey {
    static let liveValue: DatabaseService = {
        do {
            return try DatabaseService()
        } catch {
            print("❌ Critical: Database initialization failed: \(error)")
            print("ℹ️ This error typically occurs when:")
            print("   - Device storage is full")
            print("   - App doesn't have write permissions")
            print("   - Database file is corrupted")
            fatalError("Database initialization failed: \(error)")
        }
    }()
}

extension DependencyValues {
    var databaseService: DatabaseService {
        get { self[DatabaseServiceKey.self] }
        set { self[DatabaseServiceKey.self] = newValue }
    }
}
