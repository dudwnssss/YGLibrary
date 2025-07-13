//
//  BookDetailView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

import Combine
import Dependencies
import Kingfisher

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
    
    private var cancellables = Set<AnyCancellable>()
    
    init(book: Book) {
        self.state = State(book: book)
        setSubscription()
    }
    
    private func setSubscription() {
        favoriteService.favoriteISBNs
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isbns in
                guard let self else { return }
                state.isFavorite = isbns.contains(state.book.isbn)
            }
            .store(in: &cancellables)
    }
    
    func dispatch(_ action: Action) {
        switch action {
        case .onAppear:
            state.isFavorite = favoriteService.isFavorite(isbn: state.book.isbn)
        case .toggleFavorite:
            Task {
                await MainActor.run {
                    state.isLoading = true
                }
                
                do {
                    let isFavorite = try await favoriteService.toggleFavorite(state.book)
                    
                    await MainActor.run {
                        if isFavorite {
                            print("'\(state.book.title)' 즐겨찾기에 추가되었습니다")
                        } else {
                            print("'\(state.book.title)' 즐겨찾기에서 제거되었습니다")
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

struct BookDetailView: View {
    @StateObject var store: BookDetailStore
    
    var body: some View {
            VStack(alignment: .leading) {
                Text(store.book.title)
                    .bold()
                    .font(.title2)
                HStack(alignment: .top, spacing: 8) {
                    KFImage(store.book.thumbnail)
                        .aspectRatio(1.4/2, contentMode: .fit)
                        .foregroundStyle(
                            Color(uiColor: .systemGray5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading) {
                        Text("저자 : ")
                            .bold()
                        +
                        Text(store.book.authors.joined(separator: ", "))
                        Text("출판사 : ")
                            .bold()
                        +
                        Text(store.book.publisher)
                        Text("출간일 : ")
                            .bold()
                        +
                        Text("출간일")
                        Text("isbn : ")
                            .bold()
                        +
                        Text(store.book.isbn)
                        Text("정상가 : ")
                            .bold()
                        +
                        Text(store.book.pricing.displayOriginPrice)
                        Text("할인가 : ")
                            .bold()
                        +
                        Text(store.book.pricing.displaySalePrice)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                Text("책 소개")
                    .bold()
                    .font(.headline)
                Text(store.book.contents)
                Spacer()
            }
            .ygToolbar {
                YGToolbarItem.leading {
                    Button(action: {
                        store.dispatch(.pop)
                    }) {
                        Image(systemName: "arrow.left")
                    }
                    .buttonStyle(YGScaleButtonStyle())
                }
                YGToolbarItem.trailing {
                    Button(action: {
                        store.dispatch(.toggleFavorite)
                    }) {
                        Image(systemName: store.isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(store.isFavorite ? .red : .gray)
                    }
                    .buttonStyle(YGScaleButtonStyle())
                }
            }
            .onAppear {
                store.dispatch(.onAppear)
            }
            .padding(.horizontal, 16)
        }
}

