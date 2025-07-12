//
//  NetworkService.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import Foundation

struct MetaResponse<T: Decodable>: Decodable {
    let meta: Meta
    let documents: [T]
}

extension MetaResponse {
    struct Meta: Decodable {
        let totalCount: Int
        let pageableCount: Int
        let isEnd: Bool
        
        enum CodingKeys: String, CodingKey {
            case totalCount = "total_count"
            case pageableCount = "pageable_count"
            case isEnd = "is_end"
        }
    }
}

enum NewNetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(String)
    case serverError(statusCode: Int)
    case apiError(code: Int, message: String)
}

protocol NetworkService {
    func request<T: Decodable>(_ request: Request) async throws -> T
}

struct NetworkServiceImpl: NetworkService {
    let session: URLSession

    init(session: URLSession = .shared, timeout: TimeInterval = 30.0) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        
        self.session = URLSession(configuration: config)
    }
    
    func request<T>(_ request: any Request) async throws -> T where T : Decodable {
        guard let url = configURL(request: request) else {
            throw NewNetworkError.invalidURL
        }
        
        let request = configRequest(url: url, request: request)
        NetworkLogger.log(request: request)
        
        let (data, response) = try await session.data(for: request)
        NetworkLogger.log(response: response, data: data, error: nil)

        return try processResponse(data: data, response: response)
    }
    
    func configURL(request: Request) -> URL? {
        guard let url = request.baseUrl?.appendingPathComponent(request.path) else {
            return nil
        }
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return nil
        }
        
        components.queryItems = request.parameters
        
        return components.url
    }
    
    func configRequest(url: URL, request: Request) -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        request.headers?.forEach { key, value in
            urlRequest.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = request.body {
            urlRequest.httpBody = try? JSONEncoder().encode(body)
        }
        
        return urlRequest
    }
    
    private func processResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NewNetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NewNetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        
        do {
           let response = try decoder.decode(T.self, from: data)
            
           return response
            
        } catch {
           throw error
        }
    }
}

import Dependencies

private enum NetworkServiceKey: DependencyKey {
    static let liveValue: NetworkService = NetworkServiceImpl()
}

extension DependencyValues {
    var networkService: NetworkService {
        get { self[NetworkServiceKey.self] }
        set { self[NetworkServiceKey.self] = newValue }
    }
}
