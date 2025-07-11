//
//  Router.swift
//  YGLibrary
//
//  Created by 임영준 on 7/10/25.
//

import UIKit

import Dependencies

enum NavigationType {
    case push
    case present(style: UIModalPresentationStyle = .automatic)
    case fullScreenPresent
    case setRoot
}

protocol Router {
    func navigate(to: Destination, type: NavigationType)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
    func popToRoot(animated: Bool)
}

struct RouterImpl: Router {
    @Dependency(\.moduleFactory) private var factory
    private var currentNavigationController: UINavigationController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let tabBarController = window.rootViewController as? UITabBarController,
              let selectedNav = tabBarController.selectedViewController as? UINavigationController else {
            return nil
        }
        return selectedNav
    }
    
    func navigate(to destination: Destination, type: NavigationType) {
        let vc = factory.makeModule(for: destination)
        vc.hidesBottomBarWhenPushed = true
        
        switch type {
        case .push:
            currentNavigationController?.pushViewController(vc, animated: true)
            
        case .present(let style):
            vc.modalPresentationStyle = style
            currentNavigationController?.present(vc, animated: true)
            
        case .fullScreenPresent:
            vc.modalPresentationStyle = .overFullScreen
            currentNavigationController?.present(vc, animated: true)
            
        case .setRoot:
            currentNavigationController?.setViewControllers([vc], animated: false)
        }
    }

    func pop(animated: Bool) {
        currentNavigationController?.popViewController(animated: animated)
    }

    func dismiss(animated: Bool) {
        currentNavigationController?.dismiss(animated: animated)
    }

    func popToRoot(animated: Bool) {
        currentNavigationController?.popToRootViewController(animated: animated)
    }
}

import Dependencies

struct RouterKey: DependencyKey {
    static let liveValue: Router = RouterImpl()
}

extension DependencyValues {
    var router: Router {
        get { self[RouterKey.self] }
        set { self[RouterKey.self] = newValue }
    }
}
