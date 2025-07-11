//
//  NetworkLogger.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import Foundation

struct NetworkLogger {
    static func log(request: URLRequest) {
        let message = """
        ⬆️ REQUEST
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        URL: \(request.url?.absoluteString ?? "")
        METHOD: \(request.httpMethod ?? "")
        
        HEADERS: \(prettyPrintHeaders(request.allHTTPHeaderFields ?? [:]))
        AUTH: \(maskAuthToken(request.value(forHTTPHeaderField: "Authorization") ?? "none"))
        
        BODY: \(formatBody(request.httpBody?.toPrettyPrintedString ?? "none"))
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        """
        
        print(message)
    }
    
    static func log(response: URLResponse?, data: Data?, error: Error?) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        
        let responseData = data?.toPrettyPrintedString ?? "none"
        let statusCode = httpResponse.statusCode
        
        let message = """
        ⬇️ RESPONSE
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        URL: \(httpResponse.url?.absoluteString ?? "")
        STATUS: \(statusCode) \(getStatusCodeEmoji(statusCode))
        
        RESULT: \(error == nil ? "✅ Success" : "❌ Error: \(error?.localizedDescription ?? "")")
        
        DATA: \(formatResponseData(responseData))
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        """
        
        print(message)
    }
    
    // Helper methods...
    private static func prettyPrintHeaders(_ headers: [String: String]) -> String {
        guard !headers.isEmpty else { return "none" }
        return headers.map { "  \($0.key): \($0.value)" }.joined(separator: "\n")
    }
    
    private static func maskAuthToken(_ token: String) -> String {
        guard token != "none", !token.isEmpty else { return "none" }
        let prefix = String(token.prefix(10))
        return "\(prefix)...MASKED..."
    }
    
    private static func formatBody(_ body: String) -> String {
        guard body != "none" else { return "none" }
        return "\n\(body)"
    }
    
    private static func formatResponseData(_ data: String) -> String {
        guard data != "none" else { return "none" }
        return "\n\(data)"
    }
    
    private static func getStatusCodeEmoji(_ statusCode: Int) -> String {
        switch statusCode {
        case 200...299: return "✅"
        case 300...399: return "↪️"
        case 400...499: return "⚠️"
        case 500...599: return "🔴"
        default: return "❓"
        }
    }
}

extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
