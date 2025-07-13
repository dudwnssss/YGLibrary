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

final class FavoriteServiceImpl: FavoriteService, ObservableObject {
    @Published private var _favoriteISBNs: Set<String> = []
    
    var favoriteISBNs: AnyPublisher<Set<String>, Never> {
        $_favoriteISBNs.eraseToAnyPublisher()
    }
    
    // 🔧 Dependencies 대신 직접 주입
    private let repository: BookRepository
    
    init(repository: BookRepository = BookRepositoryImpl.shared) {
        self.repository = repository
        
        // 🔧 초기화 후 즉시 데이터 로드
        Task {
            try? await loadFavoriteStatus()
        }
    }
    
    func toggleFavorite(_ book: Book) async throws -> Bool {
        let isFavorited = try await repository.toggleFavorite(book)
        
        await MainActor.run {
            if isFavorited {
                _favoriteISBNs.insert(book.isbn)
            } else {
                _favoriteISBNs.remove(book.isbn)
            }
        }
        
        return isFavorited
    }
    
    func isFavorite(isbn: String) -> Bool {
        return _favoriteISBNs.contains(isbn)
    }
    
    func loadFavoriteStatus() async throws {
        print("🔍 FavoriteService.loadFavoriteStatus() 시작")
        
        do {
            let favoriteISBNs = try await repository.getAllFavoriteISBNs()
            print("📋 repository에서 가져온 ISBNs: \(favoriteISBNs)")
            
            await MainActor.run {
                _favoriteISBNs = favoriteISBNs
                print("✅ _favoriteISBNs 업데이트 완료: \(_favoriteISBNs)")
                print("📤 Publisher로 전송될 값: \(_favoriteISBNs)")
            }
        } catch {
            print("❌ loadFavoriteStatus 실패: \(error)")
            throw error
        }
    }
}

// 🔧 싱글톤 인스턴스 생성
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