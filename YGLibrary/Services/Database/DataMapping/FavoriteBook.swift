//
//  FavoriteBook.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

import GRDB

struct FavoriteBook: Codable,  FetchableRecord, MutablePersistableRecord {
    var id: Int64?
    let isbn: String
    let title: String
    let authors: [String]
    let publisher: String
    let translators: [String]
    let thumbnail: String?
    let price: Int
    let salePrice: Int
    let status: String
    let url: String?
    let contents: String
    let dateTime: Date?
    let createdAt: Date
    
    static let databaseTableName: String = "favorite_books"
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}

extension FavoriteBook {
    init(from book: Book) {
        self.id = nil
        self.isbn = book.isbn
        self.title = book.title
        self.authors = book.authors
        self.publisher = book.publisher
        self.translators = book.translators
        self.thumbnail = book.thumbnail?.absoluteString
        self.price = book.pricing.originPrice
        self.salePrice = book.pricing.salePrice
        self.status = book.status
        self.url = book.url?.absoluteString
        self.contents = book.contents
        self.dateTime = book.dateTime
        self.createdAt = Date()
    }
}

