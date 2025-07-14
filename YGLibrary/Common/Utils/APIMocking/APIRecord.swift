//
//  APIRecord.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import Foundation

struct APIRecord: Codable, Identifiable, Equatable {
    let id: UUID
    let url: String
    let method: String
    var timestamp: Date
    var originalResponse: String
    var mockedResponse: String?
    var isActive: Bool
    var statusCode: Int
    
    var displayName: String {
        let urlComponents = URLComponents(string: url)
        let path = urlComponents?.path ?? ""
        let displayPath = path.isEmpty ? url : path
        return "\(displayPath)"
    }
    
    static func == (lhs: APIRecord, rhs: APIRecord) -> Bool {
        return lhs.id == rhs.id
    }
}

