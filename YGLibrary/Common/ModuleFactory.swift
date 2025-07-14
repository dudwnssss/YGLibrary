//
//  ModuleFactory.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import UIKit
import SwiftUI

enum Destination {
    case mainTab
    case bookDetail(_ data: Book)
    case searchSortBottomSheet(_ sort: SearchSortType, onSortSelected: ((SearchSortType) -> Void))
    case favoriteSortBottomSheet(_ sort: FavoriteSortType, onSortSelected: ((FavoriteSortType) -> Void))
    case priceFilterBottomSheet(_ filter: PriceFilter, onFilterSelected: ((PriceFilter) -> Void))
    case favoriteSearchModal(onQuerySelected: ((String) -> Void))
}

protocol ModuleFactory {
    @MainActor
    func makeModule(for destination: Destination) -> UIViewController
}

struct ModuleFactoryImpl: ModuleFactory {
    func makeModule(for destination: Destination) -> UIViewController {
        switch destination {
        case .mainTab:
            let vc = MainTabBarController()
            return vc
            
        case .bookDetail(let book):
            let store = BookDetailStore(book: book)
            let view = BookDetailView(store: store)
            let vc = UIHostingController(rootView: view)
            return vc
            
        case .searchSortBottomSheet(let sort, let onSortSelected):
            let view = SortBottomSheetView(
                selectedSort: sort,
                sortOptions: SearchSortType.allCases,
                onSortSelected: onSortSelected
            )
            let vc = UIHostingController(rootView: view)
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.custom { _ in
                    240 // 🔧 핸들 + 헤더 + 2개 옵션 + 여백
                }]
                sheet.preferredCornerRadius = 16
                sheet.prefersGrabberVisible = false
            }
            return vc
            
        case .favoriteSortBottomSheet(let sort, let onSortSelected):
            let view = SortBottomSheetView(
                selectedSort: sort,
                sortOptions: FavoriteSortType.allCases,
                onSortSelected: onSortSelected
            )
            let vc = UIHostingController(rootView: view)
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.custom { _ in
                    240 // 🔧 핸들 + 헤더 + 2개 옵션 + 여백
                }]
                sheet.preferredCornerRadius = 16
                sheet.prefersGrabberVisible = false
            }
            return vc
        case .priceFilterBottomSheet(let filter, onFilterSelected: let onFilterSelected):
            let view = PriceFilterBottomSheetView(
                filter: filter,
                onFilterSelected: onFilterSelected
            )
            let vc = UIHostingController(rootView: view)
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.preferredCornerRadius = 16
                sheet.prefersGrabberVisible = false
            }
            return vc
            
        case .favoriteSearchModal(let onQuerySelected):
            let view = FavoriteSearchModalView(onQuerySelected: onQuerySelected)
            let vc = UIHostingController(rootView: view)
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.large()]
                sheet.preferredCornerRadius = 16
                sheet.prefersGrabberVisible = true
            }
            return vc
        }
    }
}

import Dependencies

struct ModuleFactoryKey: DependencyKey {
    static let liveValue: ModuleFactory = ModuleFactoryImpl()
}

extension DependencyValues {
    var moduleFactory: ModuleFactory {
        get { self[ModuleFactoryKey.self] }
        set { self[ModuleFactoryKey.self] = newValue }
    }
}
