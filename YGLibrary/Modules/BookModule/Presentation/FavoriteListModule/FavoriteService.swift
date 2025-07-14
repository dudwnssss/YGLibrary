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
        if let existingTask = pendingToggleRequests[book.id] {
            return try await existingTask.value
        }
        
        let toggleTask = Task<Bool, Error> {
            defer {
                removePendingRequest(for: book.id)
            }
            do {
                let result = try await repository.toggleFavorite(book)
                updateFavoriteStatus(uniqueId: book.id, isFavorite: result)
                return result
            } catch {
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
        do {
            let uniqueIds = try await repository.getAllFavoriteUniqueIds()
            favoriteUniqueIds = uniqueIds
        } catch {
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

@MainActor
final class FavoriteServiceImpl: FavoriteService, ObservableObject {
    @Published private var _favoriteUniqueIds: Set<String> = []
    
    var favoriteUniqueIds: AnyPublisher<Set<String>, Never> {
        $_favoriteUniqueIds.eraseToAnyPublisher()
    }
    
    private let favoriteManager: FavoriteManager
    
    init() {
        self.favoriteManager = FavoriteManager()
        
        Task {
            await syncFavoriteStatus()
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        let result = try await favoriteManager.toggleFavorite(book)
        
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
    
    
    private func syncFavoriteStatus() async {
        let currentFavorites = await favoriteManager.getAllFavoriteUniqueIds()
        _favoriteUniqueIds = currentFavorites
        print("📤 UI 상태 동기화 완료: \(_favoriteUniqueIds)")
    }
}

extension FavoriteServiceImpl {
    static let shared = FavoriteServiceImpl()
}

struct FavoriteServiceKey: DependencyKey {
    static let liveValue: FavoriteService = FavoriteServiceImpl.shared
}

extension DependencyValues {
    var favoriteService: FavoriteService {
        get { self[FavoriteServiceKey.self] }
        set { self[FavoriteServiceKey.self] = newValue }
    }
}
