//
//  YGCapsuleButton.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import SwiftUI

struct YGCapsuleButton: View {
    let icon: String?
    let title: String
    let hasBadge: Bool?
    let onTap: (() -> Void)
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                }
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .overlay(alignment: .topTrailing) {
                if let hasBadge,
                   hasBadge {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(YGScaleButtonStyle(backgroundColor: .clear))
    }
}

extension YGCapsuleButton {
    static func sortButton(onTap: @escaping (() -> Void)) -> some View {
        return Self.init(
            icon: "arrow.up.arrow.down",
            title: "정렬",
            hasBadge: nil,
            onTap: onTap
        )
    }
}
