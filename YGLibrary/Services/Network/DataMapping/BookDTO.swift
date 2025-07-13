//
//  BookDTO.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

struct BookDTO: Decodable {
    let title: String
    let contents: String
    let url: String
    let isbn: String
    let datetime: String
    let authors: [String]
    let publisher: String
    let translators: [String]
    let price: Int
    let sale_price: Int
    let thumbnail: String
    let status: String
}

struct Book: Identifiable {
    let id: String
    let title: String
    let contents: String
    let url: URL?
    let isbn: String
    let dateTime: Date?
    let authors: [String]
    let publisher: String
    let translators: [String]
    let pricing: Pricing
    let thumbnail: URL?
    let status: String
    
    struct Pricing {
        let originPrice: Int
        let salePrice: Int
        
        var displayOriginPrice: String {
            return originPrice.formatted() + "원"
        }
        var displaySalePrice: String {
            return salePrice.formatted() + "원"
        }
    }
}

extension Book {
    init(from dto: BookDTO) {
        self.id = dto.isbn
        self.title = dto.title
        self.contents = dto.contents
        self.url = URL(string: dto.url)
        self.isbn = dto.isbn
        self.dateTime = Self.parseDate(from: dto.datetime)
        self.authors = dto.authors
        self.publisher = dto.publisher
        self.translators = dto.translators
        self.pricing = .init(originPrice: max(0, dto.price), salePrice: max(0, dto.sale_price))
        self.thumbnail = URL(string: dto.thumbnail)
        self.status = dto.status
    }
    
    init(from entity: FavoriteBook) {
        self.id = entity.isbn
        self.title = entity.title
        self.contents = entity.contents
        self.url = entity.url != nil ? URL(string: entity.url!) : nil
        self.isbn = entity.isbn
        self.dateTime = entity.dateTime
        self.authors = entity.authors
        self.publisher = entity.publisher
        self.translators = entity.translators
        self.pricing = .init(originPrice: entity.price, salePrice: entity.salePrice)
        self.thumbnail = entity.thumbnail != nil ? URL(string: entity.thumbnail!) : nil
        self.status = entity.status
    }
    
    private static func parseDate(from dateString: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: dateString)
    }
}
