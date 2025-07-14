//
//  Book.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import Foundation

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
    
    var displayPrice: String {
        if pricing.salePrice > 0 {
            return pricing.displaySalePrice
        }
        return pricing.displayOriginPrice
    }
    
    var hasDiscount: Bool {
        pricing.salePrice > 0 && pricing.salePrice < pricing.originPrice
    }
    
    var hasContents: Bool {
        !contents.isEmpty
    }
}

extension Book {
    init(from dto: BookDTO) {
        let parsedDate = Self.parseDate(from: dto.datetime)
        self.id = Self
            .generateUniqueId(
                isbn: dto.isbn,
                title: dto.title,
                publisher: dto.publisher,
                dateTime: parsedDate,
                url: dto.url
            )
        self.title = dto.title
        self.contents = dto.contents
        self.url = URL(string: dto.url)
        self.isbn = dto.isbn
        self.dateTime = parsedDate
        self.authors = dto.authors
        self.publisher = dto.publisher
        self.translators = dto.translators
        self.pricing = .init(originPrice: max(0, dto.price), salePrice: max(0, dto.sale_price))
        self.thumbnail = URL(string: dto.thumbnail)
        self.status = dto.status
    }
    
    init(from entity: FavoriteBook) {
        self.id = entity.uniqueId
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
    
    // 고유 ID 생성 로직 (ISBN + 제목 + 출판사 + 출간일)
    private static func generateUniqueId(isbn: String, title: String, publisher: String, dateTime: Date?, url: String) -> String {
        let dateString = dateTime?.ISO8601Format() ?? ""
        let combinedString = "\(isbn)_\(title)_\(publisher)_\(dateString)_\(url)"
        
        return combinedString.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
    }
}

extension Book {
    private static func parseDate(from dateString: String) -> Date? {
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        guard let date = iso8601Formatter.date(from: dateString) else {
            return nil
        }
        
        return date
    }
}
