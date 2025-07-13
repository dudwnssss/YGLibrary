//
//  SuperSimpleToast.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import SwiftUI
import UIKit
import Dependencies

// MARK: - Config
struct ToastConfig {
    let message: String
    let icon: String?
    let iconColor: Color
    let duration: TimeInterval
    
    init(message: String, icon: String? = nil, iconColor: Color = .white, duration: TimeInterval = 2.0) {
        self.message = message
        self.icon = icon
        self.iconColor = iconColor
        self.duration = duration
    }
}

// MARK: - Toast View
struct ToastView: View {
    let config: ToastConfig
    @State private var scale: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(config.iconColor)
            }
            
            Text(config.message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.9))
        )
        .scaleEffect(x: 1, y: scale, anchor: .bottom)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                scale = 1
            }
        }
    }
    
    func hide() {
        withAnimation(.easeInOut(duration: 0.3)) {
            scale = 0
        }
    }
}

// MARK: - Simple Manager
final class ToastManager {
    static let shared = ToastManager()
    private var currentContainer: UIView?
    private var currentToastView: ToastView?
    
    func show(_ config: ToastConfig) {
        DispatchQueue.main.async {
            // 기존거 즉시 제거
            self.currentContainer?.removeFromSuperview()
            
            guard let vc = self.topViewController() else { return }
            
            // 새로 만들기
            let container = UIView()
            let toastView = ToastView(config: config)
            let host = UIHostingController(rootView: toastView)
            
            container.backgroundColor = .clear
            host.view.backgroundColor = .clear
            
            container.addSubview(host.view)
            vc.view.addSubview(container)
            
            // 제약조건
            container.translatesAutoresizingMaskIntoConstraints = false
            host.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                container.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16),
                container.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16),
                container.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
                container.heightAnchor.constraint(equalToConstant: 60),
                
                host.view.topAnchor.constraint(equalTo: container.topAnchor),
                host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
                host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
                host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
            ])
            
            self.currentContainer = container
            self.currentToastView = toastView
            
            // 자동 사라짐 (접히면서)
            DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                if self.currentContainer === container {
                    toastView.hide()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        if self.currentContainer === container {
                            container.removeFromSuperview()
                            self.currentContainer = nil
                            self.currentToastView = nil
                        }
                    }
                }
            }
        }
    }
    
    private func topViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first else { return nil }
        
        var top = window.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        
        if let tab = top as? UITabBarController {
            if let nav = tab.selectedViewController as? UINavigationController {
                return nav.topViewController
            }
            return tab.selectedViewController
        }
        
        if let nav = top as? UINavigationController {
            return nav.topViewController
        }
        
        return top
    }
}

// MARK: - Service
protocol ToastService {
    func show(_ config: ToastConfig)
    func showAddFavorite()
    func showRemoveFavorite()
}

struct ToastServiceImpl: ToastService {
    func show(_ config: ToastConfig) {
        ToastManager.shared.show(config)
    }
    
    func showAddFavorite() {
        show(ToastConfig(message: "즐겨찾기에 저장되었어요.", icon: "heart.fill", iconColor: .red))
    }
    
    func showRemoveFavorite() {
        show(ToastConfig(message: "즐겨찾기에서 해제되었어요.", icon: "heart.fill", iconColor: .white))
    }
}

// MARK: - Dependencies
private enum ToastServiceKey: DependencyKey {
    static let liveValue: ToastService = ToastServiceImpl()
}

extension DependencyValues {
    var toast: ToastService {
        get { self[ToastServiceKey.self] }
        set { self[ToastServiceKey.self] = newValue }
    }
}
