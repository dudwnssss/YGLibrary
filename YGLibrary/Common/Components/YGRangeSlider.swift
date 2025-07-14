//
//  YGRangeSlider.swift
//  YGLibrary
//
//  Created by 임영준 on 7/13/25.
//

import SwiftUI

struct YGRangeSlider: View {
    let minValue: Double
    let maxValue: Double
    @Binding var lowerValue: Double
    @Binding var upperValue: Double
    
    private let trackHeight: CGFloat = 4
    private let thumbDiameter: CGFloat = 24
    private let snapStep: Double = 1000 // 천원 단위 스냅 (세밀한 조작)
    
    // 천원 단위로 스냅하는 헬퍼 함수
    private func snapToThousands(_ value: Double) -> Double {
        let rounded = round(value / snapStep) * snapStep
        return max(minValue, min(maxValue, rounded))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let trackWidth = geometry.size.width
            let lowerPercent = (lowerValue - minValue) / (maxValue - minValue)
            let upperPercent = (upperValue - minValue) / (maxValue - minValue)
            let lowerOffset = trackWidth * lowerPercent
            let upperOffset = trackWidth * upperPercent
            
            ZStack(alignment: .leading) {
                // 배경 트랙
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: trackHeight)
                
                // 활성 구간 트랙
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: upperOffset - lowerOffset, height: trackHeight)
                    .offset(x: lowerOffset)
                
                // 하한 썸
                Circle()
                    .fill(Color.blue)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .offset(x: lowerOffset - thumbDiameter/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPercent = max(0, min(1, value.location.x / trackWidth))
                                let rawValue = minValue + newPercent * (maxValue - minValue)
                                let snappedValue = snapToThousands(rawValue)
                                lowerValue = min(snappedValue, upperValue - snapStep)
                            }
                    )
                
                // 상한 썸
                Circle()
                    .fill(Color.blue)
                    .frame(width: thumbDiameter, height: thumbDiameter)
                    .offset(x: upperOffset - thumbDiameter/2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newPercent = max(0, min(1, value.location.x / trackWidth))
                                let rawValue = minValue + newPercent * (maxValue - minValue)
                                let snappedValue = snapToThousands(rawValue)
                                upperValue = max(snappedValue, lowerValue + snapStep)
                            }
                    )
            }
        }
        .frame(height: thumbDiameter)
    }
}
