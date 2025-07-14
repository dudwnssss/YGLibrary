//
//  SuperSimpleToast.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import SwiftUI
import UIKit
import Dependencies

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

struct YGToastView: View {
    let config: ToastConfig
    @State private var scale: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(config.iconColor)
            }
            Text(config.message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            
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

@MainActor
final class ToastManager {
    static let shared = ToastManager()
    private var currentContainer: UIView?
    private var currentToastView: YGToastView?
    
    func show(_ config: ToastConfig) {
        self.currentContainer?.removeFromSuperview()
        
        guard let vc = self.topViewController() else { return }
            
        let container = UIView()
        let toastView = YGToastView(config: config)
        let host = UIHostingController(rootView: toastView)
            
        container.backgroundColor = .clear
        host.view.backgroundColor = .clear
        
        container.addSubview(host.view)
        vc.view.addSubview(container)
        
        container.translatesAutoresizingMaskIntoConstraints = false
        host.view.translatesAutoresizingMaskIntoConstraints = false
        
        let leadingConstraint = container.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 16)
        let trailingConstraint = container.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -16)
        let bottomConstraint = container.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            leadingConstraint,
            trailingConstraint,
            bottomConstraint,
            
            host.view.topAnchor.constraint(equalTo: container.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        let maxWidth = vc.view.frame.width - 32
        let tempSize = host.sizeThatFits(in: CGSize(width: maxWidth, height: UIView.layoutFittingExpandedSize.height))
        let dynamicHeight = max(60, min(100, tempSize.height))
        
        let heightConstraint = container.heightAnchor.constraint(equalToConstant: dynamicHeight)
        heightConstraint.isActive = true
        
        self.currentContainer = container
        self.currentToastView = toastView
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(config.duration * 1_000_000_000))
            
            if self.currentContainer === container {
                toastView.hide()
                
                try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
                
                if self.currentContainer === container {
                    container.removeFromSuperview()
                    self.currentContainer = nil
                    self.currentToastView = nil
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
@MainActor
protocol ToastService {
    func show(_ config: ToastConfig)
    func showAddFavorite()
    func showRemoveFavorite()
    func showNetworkError(_ message: String)
}

@MainActor
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
    
    func showNetworkError(_ message: String) {
        show(ToastConfig(message: message, icon: "wifi.exclamationmark", iconColor: .orange, duration: 3.0))
    }
}

// MARK: - Dependencies
private enum ToastServiceKey: DependencyKey {
    @MainActor
    static let liveValue: ToastService = ToastServiceImpl()
}

extension DependencyValues {
    var toast: ToastService {
        get { self[ToastServiceKey.self] }
        set { self[ToastServiceKey.self] = newValue }
    }
}
