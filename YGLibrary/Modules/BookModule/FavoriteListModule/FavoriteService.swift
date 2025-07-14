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
    var favoriteISBNs: AnyPublisher<Set<String>, Never> { get }

    func toggleFavorite(_ book: Book) async throws -> Bool
    func isFavorite(isbn: String) -> Bool
    func loadFavoriteStatus() async throws
}

// MARK: - Actor-based FavoriteManager
actor FavoriteManager {
    private var favoriteISBNs: Set<String> = []
    private var pendingToggleRequests: [String: Task<Bool, Error>] = [:]
    
    @Dependency(\.bookRepository) private var repository
    
    init() {
        Task {
            try? await loadInitialFavorites()
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        // Check for existing pending request - Actor automatically ensures thread safety
        if let existingTask = pendingToggleRequests[book.isbn] {
            return try await existingTask.value
        }
        
        // Create new toggle task
        let toggleTask = Task<Bool, Error> {
            defer {
                removePendingRequest(for: book.isbn)
            }
            do {
                let result = try await repository.toggleFavorite(book)
                updateFavoriteStatus(isbn: book.isbn, isFavorite: result)
                return result
            } catch {
                print("❌ FavoriteManager toggle failed: \(error)")
                throw error
            }
        }
        
        pendingToggleRequests[book.isbn] = toggleTask
        return try await toggleTask.value
    }
    
    func isFavorite(isbn: String) -> Bool {
        return favoriteISBNs.contains(isbn)
    }
    
    func getAllFavoriteISBNs() -> Set<String> {
        return favoriteISBNs
    }
    
    func loadFavoriteStatus() async throws {
        print("🔍 FavoriteManager.loadFavoriteStatus() 시작")
        
        do {
            let isbns = try await repository.getAllFavoriteISBNs()
            print("📋 repository에서 가져온 ISBNs: \(isbns)")
            
            favoriteISBNs = isbns
            print("✅ favoriteISBNs 업데이트 완료: \(favoriteISBNs)")
        } catch {
            print("❌ loadFavoriteStatus 실패: \(error)")
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func removePendingRequest(for isbn: String) {
        pendingToggleRequests.removeValue(forKey: isbn)
    }
    
    private func updateFavoriteStatus(isbn: String, isFavorite: Bool) {
        if isFavorite {
            favoriteISBNs.insert(isbn)
        } else {
            favoriteISBNs.remove(isbn)
        }
    }
    
    private func loadInitialFavorites() async throws {
        try await loadFavoriteStatus()
    }
}

// MARK: - ObservableObject Wrapper for SwiftUI
@MainActor
final class FavoriteServiceImpl: FavoriteService, ObservableObject {
    @Published private var _favoriteISBNs: Set<String> = []
    
    var favoriteISBNs: AnyPublisher<Set<String>, Never> {
        $_favoriteISBNs.eraseToAnyPublisher()
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
    
    func isFavorite(isbn: String) -> Bool {
        return _favoriteISBNs.contains(isbn)
    }
    
    func loadFavoriteStatus() async throws {
        try await favoriteManager.loadFavoriteStatus()
        await syncFavoriteStatus()
    }
    
    // MARK: - Private Methods
    
    private func syncFavoriteStatus() async {
        let currentFavorites = await favoriteManager.getAllFavoriteISBNs()
        _favoriteISBNs = currentFavorites
        print("📤 UI 상태 동기화 완료: \(_favoriteISBNs)")
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
