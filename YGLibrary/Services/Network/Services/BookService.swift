//
//  BookService.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import Foundation

import Dependencies

protocol BookService: Sendable {
    func getSearchBook() async throws -> BaseResponse<Book>
}

struct BookServiceImpl: BookService {
    @Dependency(\.networkService) private var service
    
    func getSearchBook() async throws -> BaseResponse<Book> {
        return try await service.request(
                BookRequest.searchBook(
                    query: "안녕",
                    sort: nil,
                    page: nil,
                    size: nil,
                    target: nil
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
