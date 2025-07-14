//
//  APIMockingTool.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import UIKit

final class APIMockingTool {
    static let shared = APIMockingTool()
    
    private var floatingButton: FloatingButton?
    
    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showMockingTool),
            name: NSNotification.Name("ShowApiMockingTool"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setup() {
#if DEBUG
        registerURLProtocol()
        addFloatingButton()
#endif
    }
    
    private func registerURLProtocol() {
        URLProtocol.registerClass(APIMockingProtocol.self)
    }
    
    private func addFloatingButton() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.floatingButton?.removeFromSuperview()
            
            let button = FloatingButton(
                frame: CGRect(
                    x: UIScreen.main.bounds.width - 70,
                    y: UIScreen.main.bounds.height - 200,
                    width: 50,
                    height: 50
                )
            )
            
            guard let keyWindow = self.getKeyWindow() else { return }
            keyWindow.addSubview(button)
            
            self.floatingButton = button
        }
    }
    
    private func getKeyWindow() -> UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
        
        if let windowScene = scenes.first {
            return windowScene.windows.first { $0.isKeyWindow }
        }
        
        return nil
    }
    
    @objc private func showMockingTool() {
        let mockingVC = APIMockingViewController()
        let navigationController = UINavigationController(rootViewController: mockingVC)
        
        // 스타일 설정
        navigationController.modalPresentationStyle = .fullScreen
        if #available(iOS 13.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithDefaultBackground()
            navigationController.navigationBar.standardAppearance = navigationBarAppearance
            navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        }
        
        DispatchQueue.main.async {
            self.getKeyWindow()?.rootViewController?.present(navigationController, animated: true)
        }
    }
}
