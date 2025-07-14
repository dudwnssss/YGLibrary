//
//  SceneDelegate.swift
//  YGLibrary
//
//  Created by 임영준 on 7/10/25.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        let vc = MainTabBarController()
        window?.rootViewController = vc
    }
}
