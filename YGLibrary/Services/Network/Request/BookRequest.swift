//
//  BookRequest.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import Foundation

enum BookRequest: Request {
    case searchBook(query: String, sort: String?, page: Int?, size: Int?, target: Int?)

    var baseUrl: URL? {
        switch self {
        case .searchBook:
            return URL(string: Secrets.baseURL)
        }
    }

    var path: String {
        switch self {
        case .searchBook:
            return "v3/search/book"
        }
    }

    var method: NetworkMethod {
        switch self {
        case .searchBook:
            return .get
        }
    }

    var parameters: [URLQueryItem]? {
        switch self {
        case .searchBook(let query, let sort, let page, let size, let target):
            var params = [URLQueryItem(name: "query", value: query)]
            
            if let sort {
                params.append(URLQueryItem(name: "sort", value: sort))
            }
            if let page {
                params.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let size {
                params.append(URLQueryItem(name: "size", value: "\(size)"))
            }
            if let target {
                params.append(URLQueryItem(name: "target", value: "\(target)"))
            }
            
            return params
        }
    }

    var headers: [String : String]? {
        switch self {
        case .searchBook:
            return [
                "Authorization": "KakaoAK \(Secrets.restAPIKey)"
            ]
        }
    }

    var body: (any Encodable)? {
        switch self {
        case .searchBook:
            return nil
        }
    }
}
