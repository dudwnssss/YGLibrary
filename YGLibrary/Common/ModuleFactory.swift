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
    case sortBottomSheet(_ sort: SearchSortType, onSortSelected: ((SearchSortType) -> Void))
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
            
        case .sortBottomSheet(let sort, let onSortSelected):
            let view = SortBottomSheetView(selectedSort: sort, onSortSelected: onSortSelected)
            let vc = UIHostingController(rootView: view)
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.custom { _ in
                    200
                }]
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
