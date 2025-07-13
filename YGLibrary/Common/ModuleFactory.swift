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
}

protocol ModuleFactory {
    @MainActor
    func makeModule(for destination: Destination) -> UIViewController
}

struct ModuleFactoryImpl: ModuleFactory {
    func makeModule(for destination: Destination) -> UIViewController {
        switch destination {
        case .mainTab:
            return MainTabBarController()
            
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