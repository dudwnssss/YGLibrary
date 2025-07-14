//
//  HapticGenerator.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import UIKit

import Dependencies

struct HapticGenerator {
    enum HapticType {
        case light
        case medium
        case heavy
        case selection
        case success
        case warning
        case error
    }
    
    func generateFeedback(_ type: HapticType) {
        switch type {
        case .light:
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        case .medium:
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .heavy:
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()
        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)
        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}

extension HapticGenerator: DependencyKey {
    static let liveValue = HapticGenerator()
}

extension DependencyValues {
    var haptic: HapticGenerator {
        get { self[HapticGenerator.self] }
        set { self[HapticGenerator.self] = newValue }
    }
}
