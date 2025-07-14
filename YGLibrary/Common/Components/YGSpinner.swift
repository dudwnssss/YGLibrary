//
//  YGSpinner.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import SwiftUI

struct SpinnerView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.6)  // 반원보다 조금 더 긴 호
            .stroke(
                AngularGradient(
                    colors: [Color.blue.opacity(0.5), Color.blue],
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(360)
                ),
                style: StrokeStyle(lineWidth: 3, lineCap: .round)
            )
            .frame(width: 36, height: 36)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.0)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}
