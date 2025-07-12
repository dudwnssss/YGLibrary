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
    let thumbnail: String
    let price: Int
    let salePrice: Int
    let status: String
    let url: String
    let createdAt: Date
    
    static let databaseTableName: String = "favorite_books"
    
    mutating func didInsert(with rowID: Int64, for column: String?) {
        id = rowID
    }
}



