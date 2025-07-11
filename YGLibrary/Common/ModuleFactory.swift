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
}

protocol ModuleFactory {
    func makeModule(for destination: Destination) -> UIViewController
}

struct ModuleFactoryImpl: ModuleFactory {
    func makeModule(for destination: Destination) -> UIViewController {
        switch destination {
        case .mainTab:
            return MainTabBarController()
        case .bookDetail(let book):
            return UIHostingController(rootView: BookDetailView(book: book))
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
