//
//  APIMockingProtocol.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import Foundation

final class APIMockingProtocol: URLProtocol {
    
    private static let sessionKey = "ApiMockingProtocolKey"
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    
    override class func canInit(with request: URLRequest) -> Bool {
        guard let url = request.url?.absoluteString,
              let method = request.httpMethod else {
            return false
        }
        
        if URLProtocol.property(forKey: sessionKey, in: request) != nil {
            return false
        }
        
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
        return super.requestIsCacheEquivalent(a, to: b)
    }
    
    override func startLoading() {
        guard let client = client,
              let url = request.url?.absoluteString,
              let method = request.httpMethod else {
            return
        }
        
        let mutableRequest = (request as NSURLRequest).mutableCopy() as! NSMutableURLRequest
        URLProtocol.setProperty(true, forKey: APIMockingProtocol.sessionKey, in: mutableRequest)
        
        if let mockData = APIMockingManager.shared.getMockedResponse(for: url, method: method) {
            DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.1) {
                let response = HTTPURLResponse(
                    url: self.request.url!,
                    statusCode: 200,
                    httpVersion: "HTTP/1.1",
                    headerFields: ["Content-Type": "application/json"]
                )!
                
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                self.client?.urlProtocol(self, didLoad: mockData)
                self.client?.urlProtocolDidFinishLoading(self)
            }
            
            APIMockingManager.shared.updateTimestampForMockedRequest(url: url, method: method)
            return
        }
        
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = nil
        
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        dataTask = session?.dataTask(with: request) { [weak self] data, response, error in
            guard let self, let client = self.client else { return }
            
            if let error = error {
                client.urlProtocol(self, didFailWithError: error)
                return
            }
            
            if let response = response {
                client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                
                if let data = data,
                   let responseString = String(data: data, encoding: .utf8),
                   let contentType = response.mimeType,
                   contentType.contains("json") {
                    
                    APIMockingManager.shared.addRecord(
                        url: url,
                        method: method,
                        response: responseString,
                        statusCode: statusCode
                    )
                }
            }
            
            if let data = data {
                client.urlProtocol(self, didLoad: data)
            }
            
            client.urlProtocolDidFinishLoading(self)
        }
        
        dataTask?.resume()
    }
    
    override func stopLoading() {
        dataTask?.cancel()
    }
}

extension APIMockingProtocol: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        client?.urlProtocol(self, didLoad: data)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        completionHandler(.allow)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }
}
