//
//  DatabaseService.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import Foundation

import GRDB

final class DatabaseService {
    static let shared = DatabaseService()
    private let dbQueue: DatabaseQueue
    
    private init() {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let databasePath = "\(documentsPath)/YGLibrary.sqlite"
        
        do {
            dbQueue = try DatabaseQueue(path: databasePath)
            try createTables()
        } catch {
            fatalError("Database setup failed: \(error)")
        }
    }
    
    private func createTables() throws {
        try dbQueue.write { db in
            try db.create(table: "favorite_books", ifNotExists: true) { t in
                t.autoIncrementedPrimaryKey("id")
                t.column("isbn", .text).notNull().unique(onConflict: .replace)
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
        }
    }
    
    func write<T>(_ updates: (Database) throws -> T) throws -> T {
        return try dbQueue.write(updates)
    }
    
    func read<T>(_ value: (Database) throws -> T) throws -> T {
        return try dbQueue.read(value)
    }
}

import Dependencies

struct DatabaseServiceKey: DependencyKey {
    static let liveValue: DatabaseService = DatabaseService.shared
}

extension DependencyValues {
    var databaseService: DatabaseService {
        get { self[DatabaseServiceKey.self] }
        set { self[DatabaseServiceKey.self] = newValue }
    }
}
