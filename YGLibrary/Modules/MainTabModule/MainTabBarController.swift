//
//  MainTabBarController.swift
//  YGLibrary
//
//  Created by 임영준 on 7/10/25.
//

import UIKit
import SwiftUI

import Dependencies

enum Tab {
    case search
    case favorite
}

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupTabs()
        configure()
    }
    
    private func setupTabs() {
        let searchListView = SearchListView()
        let searchHostingController = UIHostingController(rootView: searchListView)
        searchHostingController.tabBarItem = UITabBarItem(
            title: "검색",
            image: UIImage(systemName: "magnifyingglass"),
            tag: 0
        )
        
        let favoriteListView = FavoriteListView()
        let favoriteHostingController = UIHostingController(rootView: favoriteListView)
        favoriteHostingController.tabBarItem = UITabBarItem(
            title: "즐겨찾기",
            image: UIImage(systemName: "heart.fill"),
            tag: 1
        )
        
        let searchNavController = UINavigationController(rootViewController: searchHostingController)
        let favoriteNavController = UINavigationController(rootViewController: favoriteHostingController)
        
        setViewControllers([searchNavController, favoriteNavController], animated: false)
    }
    private func configure() {
        let appearance = UITabBarAppearance()
        
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        @Dependency(\.haptic) var haptic
        haptic.generateFeedback(.light)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController == selectedViewController {
            scrollToTop(in: viewController)
        }
        
        return true
    }
        
    private func scrollToTop(in viewController: UIViewController) {
        var targetViewController: UIViewController = viewController
        
        if let navController = viewController as? UINavigationController,
           let topVC = navController.topViewController {
            targetViewController = topVC
        }
        findAndScrollToTop(in: targetViewController.view)
    }
    
    private func findAndScrollToTop(in view: UIView) {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.setContentOffset(.zero, animated: true)
                return
            } else {
                findAndScrollToTop(in: subview)
            }
        }
    }
}
