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

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(String)
    case serverError(statusCode: Int)
    case apiError(code: Int, message: String)
    case networkUnavailable
    case timeout
    case connectionLost
}

protocol NetworkService {
    func request<T>(_ request: Request) async throws -> T where T: Decodable
}

struct NetworkServiceImpl: NetworkService {
    let session: URLSession

    init(session: URLSession = .shared, timeout: TimeInterval = 30.0) {
        let config = URLSessionConfiguration.default
        #if DEBUG
        config.protocolClasses = [APIMockingProtocol.self] + (config.protocolClasses ?? [])
        #endif
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout
        
        self.session = URLSession(configuration: config)
    }
    
    func request<T>(_ request: any Request) async throws -> T where T : Decodable {
        guard let url = configURL(request: request) else {
            throw NetworkError.invalidURL
        }
        
        let urlRequest = configRequest(url: url, request: request)
        NetworkLogger.log(request: urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            NetworkLogger.log(response: response, data: data, error: nil)
            
            return try processResponse(data: data, response: response)
        } catch {
            NetworkLogger.log(response: nil, data: nil, error: error)
            throw mapNetworkError(error)
        }
    }
    
    private func mapNetworkError(_ error: Error) -> NetworkError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .timeout
            case .cannotConnectToHost, .cannotFindHost:
                return .connectionLost
            default:
                return .connectionLost
            }
        }
        
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        return .connectionLost
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
    
    private func processResponse<T>(data: Data, response: URLResponse) throws -> T where T: Decodable {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        
        do {
           let response = try decoder.decode(T.self, from: data)
            
           return response
            
        } catch {
           throw NetworkError.decodingError(error.localizedDescription)
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

// MARK: - NetworkError Extensions for User-Friendly Messages
extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "잘못된 URL입니다."
        case .invalidResponse:
            return "잘못된 응답입니다."
        case .decodingError(let message):
            return "데이터 파싱 오류: \(message)"
        case .serverError(let statusCode):
            return "서버 오류 (상태 코드: \(statusCode))"
        case .apiError(let code, let message):
            return "API 오류 (코드: \(code), 메시지: \(message))"
        case .networkUnavailable:
            return "네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .connectionLost:
            return "네트워크 연결이 끊어졌습니다."
        }
    }
}
