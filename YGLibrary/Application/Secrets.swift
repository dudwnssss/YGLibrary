//
//  Secrets.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import Foundation

enum Secrets {
    private static func getValue(for key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("Key '\(key)' not found in Info.plist")
        }
        return value
    }
    
    static var baseURL: String { getValue(for: "BASE_URL") }
    static var restAPIKey: String { getValue(for: "REST_API_KEY") }
}
