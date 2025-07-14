//
//  YGScaleButtonStyle.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import SwiftUI

struct YGScaleButtonStyle: ButtonStyle {
    @State private var isPressed = false
    let scale: CGFloat
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let duration: Double
    let minTapTargetSize: CGSize = CGSize(width: 44, height: 44)
    
    init(
        scale: CGFloat = 0.95,
        backgroundColor: Color = Color(uiColor: .systemGray6),
        cornerRadius: CGFloat = 8,
        duration: Double = 0.1
    ) {
        self.scale = scale
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.duration = duration
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(isPressed ? backgroundColor : Color.clear)
                    .frame(minWidth: minTapTargetSize.width, minHeight: minTapTargetSize.height)
            )
            .overlay(
                Rectangle()
                    .fill(Color.clear)
                    .frame(minWidth: minTapTargetSize.width, minHeight: minTapTargetSize.height)
                    .contentShape(Rectangle())
            )
            .scaleEffect(isPressed ? scale : 1.0)
            .animation(.easeOut(duration: duration), value: isPressed)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in isPressed = true }
                    .onEnded { _ in isPressed = false }
            )
    }
}
