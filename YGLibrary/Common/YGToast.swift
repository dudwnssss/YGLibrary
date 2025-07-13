//
//  YGToast.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import SwiftUI

// MARK: - Toast Configuration
struct ToastConfig {
    let message: String
    let icon: String?
    let duration: TimeInterval
    let actionText: String?
    let action: (() -> Void)?
    
    init(
        message: String,
        icon: String? = nil,
        duration: TimeInterval = 3.0,
        actionText: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.message = message
        self.icon = icon
        self.duration = duration
        self.actionText = actionText
        self.action = action
    }
}

// MARK: - Toast View
struct YGToast: View {
    let config: ToastConfig
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            // 아이콘
            if let icon = config.icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // 메시지
            Text(config.message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // 액션 버튼
            if let actionText = config.actionText {
                Button(action: {
                    config.action?()
                    onDismiss()
                }) {
                    Text(actionText)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.9))
        )
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .offset(y: isVisible ? 0 : 100)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isVisible)
        .onAppear {
            isVisible = true
            
            // 자동 사라짐
            DispatchQueue.main.asyncAfter(deadline: .now() + config.duration) {
                dismiss()
            }
        }
        .onTapGesture {
            dismiss()
        }
    }
    
    private func dismiss() {
        isVisible = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}

// MARK: - Toast Manager
class ToastManager: ObservableObject {
    static let shared = ToastManager()
    
    @Published var toasts: [ToastItem] = []
    
    private init() {}
    
    struct ToastItem: Identifiable {
        let id = UUID()
        let config: ToastConfig
    }
    
    func show(_ config: ToastConfig) {
        let item = ToastItem(config: config)
        
        DispatchQueue.main.async {
            // 기존 토스트가 있으면 제거
            self.toasts.removeAll()
            self.toasts.append(item)
        }
    }
    
    func dismiss(_ item: ToastItem) {
        DispatchQueue.main.async {
            self.toasts.removeAll { $0.id == item.id }
        }
    }
    
    func dismissAll() {
        DispatchQueue.main.async {
            self.toasts.removeAll()
        }
    }
}

// MARK: - Toast Container View
struct ToastContainer<Content: View>: View {
    let content: Content
    @StateObject private var toastManager = ToastManager.shared
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
            
            // 토스트 오버레이
            VStack {
                Spacer()
                
                ForEach(toastManager.toasts) { item in
                    YGToast(config: item.config) {
                        toastManager.dismiss(item)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: toastManager.toasts.count)
        }
    }
}

// MARK: - Convenience Extensions
extension ToastManager {
    func showSuccess(_ message: String, actionText: String? = nil, action: (() -> Void)? = nil) {
        show(ToastConfig(
            message: message,
            icon: "checkmark.circle.fill",
            actionText: actionText,
            action: action
        ))
    }
    
    func showError(_ message: String, actionText: String? = nil, action: (() -> Void)? = nil) {
        show(ToastConfig(
            message: message,
            icon: "exclamationmark.circle.fill",
            actionText: actionText,
            action: action
        ))
    }
    
    func showInfo(_ message: String, actionText: String? = nil, action: (() -> Void)? = nil) {
        show(ToastConfig(
            message: message,
            icon: "info.circle.fill",
            actionText: actionText,
            action: action
        ))
    }
    
    func showFavorite(_ message: String, actionText: String? = nil, action: (() -> Void)? = nil) {
        show(ToastConfig(
            message: message,
            icon: "heart.fill",
            actionText: actionText,
            action: action
        ))
    }
}

#Preview {
    ToastContainer {
        VStack(spacing: 20) {
            Text("토스트 테스트")
                .font(.title)
                .padding()
            
            VStack(spacing: 16) {
                Button("성공 토스트") {
                    ToastManager.shared.showSuccess("즐겨찾기에 추가되었습니다")
                }
                
                Button("에러 토스트") {
                    ToastManager.shared.showError("네트워크 오류가 발생했습니다")
                }
                
                Button("정보 토스트") {
                    ToastManager.shared.showInfo("새로운 업데이트가 있습니다")
                }
                
                Button("즐겨찾기 토스트 (액션 포함)") {
                    ToastManager.shared.showFavorite("기본 폴더에서 해제되었어요.", actionText: "변경") {
                        print("변경 버튼 클릭됨")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
    }
}
