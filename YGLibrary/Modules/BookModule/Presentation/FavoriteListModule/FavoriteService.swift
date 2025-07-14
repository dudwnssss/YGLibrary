//
//  FavoriteService.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

import Combine
import Dependencies

protocol FavoriteService {
    var favoriteUniqueIds: AnyPublisher<Set<String>, Never> { get }

    func toggleFavorite(_ book: Book) async throws -> Bool
    func isFavorite(uniqueId: String) -> Bool
    func loadFavoriteStatus() async throws
}

// MARK: - Actor-based FavoriteManager
actor FavoriteManager {
    private var favoriteUniqueIds: Set<String> = []
    private var pendingToggleRequests: [String: Task<Bool, Error>] = [:]
    
    @Dependency(\.bookRepository) private var repository
    
    init() {
        Task {
            try? await loadInitialFavorites()
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        // Check for existing pending request - Actor automatically ensures thread safety
        if let existingTask = pendingToggleRequests[book.id] {
            return try await existingTask.value
        }
        
        // Create new toggle task
        let toggleTask = Task<Bool, Error> {
            defer {
                removePendingRequest(for: book.id)
            }
            do {
                let result = try await repository.toggleFavorite(book)
                updateFavoriteStatus(uniqueId: book.id, isFavorite: result)
                return result
            } catch {
                print("❌ FavoriteManager toggle failed: \(error)")
                throw error
            }
        }
        
        pendingToggleRequests[book.id] = toggleTask
        return try await toggleTask.value
    }
    
    func isFavorite(uniqueId: String) -> Bool {
        return favoriteUniqueIds.contains(uniqueId)
    }
    
    func getAllFavoriteUniqueIds() -> Set<String> {
        return favoriteUniqueIds
    }
    
    func loadFavoriteStatus() async throws {
        print("🔍 FavoriteManager.loadFavoriteStatus() 시작")
        
        do {
            let uniqueIds = try await repository.getAllFavoriteUniqueIds()
            print("📋 repository에서 가져온 UniqueIds: \(uniqueIds)")
            
            favoriteUniqueIds = uniqueIds
            print("✅ favoriteUniqueIds 업데이트 완료: \(favoriteUniqueIds)")
        } catch {
            print("❌ loadFavoriteStatus 실패: \(error)")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func removePendingRequest(for uniqueId: String) {
        pendingToggleRequests.removeValue(forKey: uniqueId)
    }
    
    private func updateFavoriteStatus(uniqueId: String, isFavorite: Bool) {
        if isFavorite {
            favoriteUniqueIds.insert(uniqueId)
        } else {
            favoriteUniqueIds.remove(uniqueId)
        }
    }
    
    private func loadInitialFavorites() async throws {
        try await loadFavoriteStatus()
    }
}

// MARK: - ObservableObject Wrapper for SwiftUI
@MainActor
final class FavoriteServiceImpl: FavoriteService, ObservableObject {
    @Published private var _favoriteUniqueIds: Set<String> = []
    
    var favoriteUniqueIds: AnyPublisher<Set<String>, Never> {
        $_favoriteUniqueIds.eraseToAnyPublisher()
    }
    
    private let favoriteManager: FavoriteManager
    
    init() {
        self.favoriteManager = FavoriteManager()
        
        // Actor의 상태를 주기적으로 동기화
        Task {
            await syncFavoriteStatus()
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        let result = try await favoriteManager.toggleFavorite(book)
        
        // UI 상태 즉시 업데이트 (MainActor에서 실행)
        await syncFavoriteStatus()
        
        return result
    }
    
    func isFavorite(uniqueId: String) -> Bool {
        return _favoriteUniqueIds.contains(uniqueId)
    }
    
    func loadFavoriteStatus() async throws {
        try await favoriteManager.loadFavoriteStatus()
        await syncFavoriteStatus()
    }
    
    // MARK: - Private Methods
    
    private func syncFavoriteStatus() async {
        let currentFavorites = await favoriteManager.getAllFavoriteUniqueIds()
        _favoriteUniqueIds = currentFavorites
        print("📤 UI 상태 동기화 완료: \(_favoriteUniqueIds)")
    }
}

// MARK: - Singleton for Dependencies
extension FavoriteServiceImpl {
    static let shared = FavoriteServiceImpl()
}

// MARK: - Dependencies Integration
struct FavoriteServiceKey: DependencyKey {
    static let liveValue: FavoriteService = FavoriteServiceImpl.shared
}

extension DependencyValues {
    var favoriteService: FavoriteService {
        get { self[FavoriteServiceKey.self] }
        set { self[FavoriteServiceKey.self] = newValue }
    }
}
