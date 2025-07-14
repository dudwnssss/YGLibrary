//
//  BookDetailStore.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import Foundation

import Combine
import Dependencies

final class BookDetailStore: Store {
    enum Action {
        case onAppear
        case toggleFavorite
        case pop
    }
    
    struct State {
        let book: Book
        var isFavorite: Bool = false
        var isLoading: Bool = false
        var isError: Bool = false
        
        init(book: Book) {
            self.book = book
        }
    }
    
    @Published private(set) var state: State
    @Dependency(\.router) private var router
    @Dependency(\.favoriteService) private var favoriteService
    @Dependency(\.toast) private var toast
    
    private var cancellables = Set<AnyCancellable>()
    
    init(book: Book) {
        self.state = State(book: book)
        setSubscription()
    }
    
    private func setSubscription() {
        favoriteService.favoriteUniqueIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ids in
                guard let self else { return }
                state.isFavorite = ids.contains(state.book.id)
            }
            .store(in: &cancellables)
    }
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            state.isFavorite = favoriteService.isFavorite(uniqueId: state.book.id)
        case .toggleFavorite:
            // Actor handles concurrency automatically
            Task {
                await MainActor.run {
                    state.isLoading = true
                }
                
                do {
                    let isFavorite = try await favoriteService.toggleFavorite(state.book)
                    
                    await MainActor.run {
                        if isFavorite {
                            toast.showAddFavorite()
                        } else {
                            toast.showRemoveFavorite()
                        }
                    }
                } catch {
                    await MainActor.run {
                        state.isError = true
                    }
                }
                
                await MainActor.run {
                    state.isLoading = false
                }
            }
        case .pop:
            router.pop(animated: true)
        }
    }
}
