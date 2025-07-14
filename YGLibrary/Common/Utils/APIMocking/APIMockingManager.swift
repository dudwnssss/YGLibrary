//
//  APIMockingManager.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import Foundation

class APIMockingManager {
    static let shared = APIMockingManager()
    
    private let storageKey = "api_mocking_records"
    private(set) var records: [APIRecord] = []
    
    private let backgroundQueue = DispatchQueue(label: "api.mocking.queue", qos: .utility)
    private let recordsQueue = DispatchQueue(label: "api.mocking.records", qos: .userInitiated)
    private let cacheQueue = DispatchQueue(label: "api.mocking.cache", qos: .utility)
    
    private var inMemoryCache: [String: Data] = [:]
    
    private var pendingSaveTimer: Timer?
    
    private init() {
        loadRecords()
    }
    
    private func loadRecords() {
        backgroundQueue.async { [weak self] in
            guard let self = self else { return }
            guard let data = UserDefaults.standard.data(forKey: self.storageKey) else { return }
            
            do {
                let loadedRecords = try JSONDecoder().decode([APIRecord].self, from: data)
                let sortedRecords = loadedRecords.sorted(by: { $0.timestamp > $1.timestamp })
                
                DispatchQueue.main.async {
                    self.records = sortedRecords
                    self.buildCache()
                }
            } catch {
                print("API 모킹 데이터 로드 에러: \(error)")
            }
        }
    }
    
    private func buildCache() {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.inMemoryCache.removeAll()
            
            for record in self.records {
                if record.isActive, let mockedResponse = record.mockedResponse {
                    let key = "\(record.method):\(record.url)"
                    self.inMemoryCache[key] = mockedResponse.data(using: .utf8)
                }
            }
        }
    }
    
    private func scheduleDelayedSave() {
        DispatchQueue.main.async { [weak self] in
            self?.pendingSaveTimer?.invalidate()
            self?.pendingSaveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self?.saveRecords()
            }
        }
    }
    
    private func saveRecords() {
        let recordsToSave = records
        backgroundQueue.async {
            do {
                let data = try JSONEncoder().encode(recordsToSave)
                UserDefaults.standard.set(data, forKey: self.storageKey)
            } catch {
                print("API 모킹 데이터 저장 에러: \(error)")
            }
        }
    }
    
    func addRecord(url: String, method: String, response: String, statusCode: Int) {
        if response.count > 100000 {
            return
        }
        
        recordsQueue.async { [weak self] in
            guard let self = self else { return }
            
            let formattedResponse = self.prettyPrintJSON(response)
            
            DispatchQueue.main.async {
                if let index = self.records.firstIndex(where: { $0.url == url && $0.method == method }) {
                    var updatedRecord = self.records[index]
                    updatedRecord.originalResponse = formattedResponse
                    updatedRecord.timestamp = Date()
                    updatedRecord.statusCode = statusCode
                    self.records.remove(at: index)
                    self.records.insert(updatedRecord, at: 0)
                } else {
                    let newRecord = APIRecord(
                        id: UUID(),
                        url: url,
                        method: method,
                        timestamp: Date(),
                        originalResponse: formattedResponse,
                        mockedResponse: nil,
                        isActive: false,
                        statusCode: statusCode
                    )
                    self.records.insert(newRecord, at: 0)
                }
                
                if self.records.count > 50 {
                    self.records = Array(self.records.prefix(50))
                }
                
                self.scheduleDelayedSave()
            }
        }
    }
    
    private func prettyPrintJSON(_ jsonString: String) -> String {
        if jsonString.count > 10000 {
            return jsonString
        }
        
        guard let data = jsonString.data(using: .utf8),
              let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return jsonString
        }
        return prettyString
    }
    
    func updateMockedResponse(for id: UUID, with json: String, isActive: Bool) {
        recordsQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                guard let index = self.records.firstIndex(where: { $0.id == id }) else { return }
                
                var updatedRecord = self.records[index]
                updatedRecord.mockedResponse = json
                updatedRecord.isActive = isActive
                
                self.records[index] = updatedRecord
                
                self.updateCache(for: updatedRecord)
                
                self.scheduleDelayedSave()
            }
        }
    }
    
    // 캐시 업데이트
    private func updateCache(for record: APIRecord) {
        cacheQueue.async { [weak self] in
            guard let self = self else { return }
            
            let key = "\(record.method):\(record.url)"
            
            if record.isActive, let mockedResponse = record.mockedResponse {
                self.inMemoryCache[key] = mockedResponse.data(using: .utf8)
            } else {
                self.inMemoryCache.removeValue(forKey: key)
            }
        }
    }
    
    func updateTimestampForMockedRequest(url: String, method: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let index = self.records.firstIndex(where: { $0.url == url && $0.method == method && $0.isActive }) {
                var updatedRecord = self.records[index]
                updatedRecord.timestamp = Date()
                
                self.records.remove(at: index)
                
                self.records.insert(updatedRecord, at: 0)
                
                self.scheduleDelayedSave()
            }
        }
    }
    
    func disableAllMocks() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.records = self.records.map { record in
                var updatedRecord = record
                updatedRecord.isActive = false
                return updatedRecord
            }
            
            self.cacheQueue.async {
                self.inMemoryCache.removeAll()
            }
            
            self.scheduleDelayedSave()
        }
    }
    
    func getMockedResponse(for url: String, method: String) -> Data? {
        let key = "\(method):\(url)"
        
        return cacheQueue.sync {
            return inMemoryCache[key]
        }
    }
    
    func deleteRecord(id: UUID) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let record = self.records.first(where: { $0.id == id }) {
                let key = "\(record.method):\(record.url)"
                self.cacheQueue.async {
                    self.inMemoryCache.removeValue(forKey: key)
                }
            }
            
            self.records.removeAll(where: { $0.id == id })
            self.scheduleDelayedSave()
        }
    }
    
    func sortRecordsByDate() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.records.sort(by: { $0.timestamp > $1.timestamp })
            self.scheduleDelayedSave()
        }
    }
    
    func deleteAllRecords() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.records.removeAll()
            
            self.cacheQueue.async {
                self.inMemoryCache.removeAll()
            }
            
            self.scheduleDelayedSave()
        }
    }
}
