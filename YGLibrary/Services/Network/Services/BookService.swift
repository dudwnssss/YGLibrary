//
//  BookService.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import Foundation

import Dependencies

protocol BookService: Sendable {
    func getSearchBook(
        query: String,
        sort: SearchSortType,
        page: Int?,
        size: Int?,
        target: String?
    ) async throws -> MetaResponse<BookDTO>
}

extension BookService {
    func getSearchBook(
        query: String,
        sort: SearchSortType,
        page: Int? = nil,
        size: Int? = 20,
        target: String? = nil
    ) async throws -> MetaResponse<BookDTO> {
        return try await getSearchBook(
            query: query,
            sort: sort,
            page: page,
            size: size,
            target: target
        )
    }
}

struct BookServiceImpl: BookService {
    @Dependency(\.networkService) private var service
    
    func getSearchBook(
        query: String,
        sort: SearchSortType,
        page: Int?,
        size: Int?,
        target: String?
    ) async throws -> MetaResponse<BookDTO> {
        return try await service.request(
                BookRequest.searchBook(
                    query: query,
                    sort: sort.rawValue,
                    page: page,
                    size: size,
                    target: target
                )
        )
    }
}

import Dependencies

private enum BookServiceKey: DependencyKey {
    static let liveValue: BookService = BookServiceImpl()
}

extension DependencyValues {
    var bookService: BookService {
        get { self[BookServiceKey.self] }
        set { self[BookServiceKey.self] = newValue }
    }
}
