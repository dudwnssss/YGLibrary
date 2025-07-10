//
//  Request.swift
//  YGLibrary
//
//  Created by 임영준 on 7/10/25.
//

import Foundation

enum NetworkMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol Request {
    var baseUrl: URL? { get }
    var path: String { get }
    var method: NetworkMethod { get }
    var parameters: [URLQueryItem]? { get }
    var headers: [String: String]? { get }
    var body: Encodable? { get }
}
