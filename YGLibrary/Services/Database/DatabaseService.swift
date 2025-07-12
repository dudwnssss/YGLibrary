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
                t.column("authors", .blob).notNull() // JSON으로 저장
                t.column("publisher", .text).notNull()
                t.column("thumbnail", .text)
                t.column("price", .integer)
                t.column("salePrice", .integer)
                t.column("status", .text)
                t.column("url", .text)
                t.column("createdAt", .datetime).notNull()
            }
        }
    }
}
