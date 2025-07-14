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
