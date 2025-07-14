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
                                let newValue = minValue + newPercent * (maxValue - minValue)
                                lowerValue = min(newValue, upperValue - 2000)
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
                                let newValue = minValue + newPercent * (maxValue - minValue)
                                upperValue = max(newValue, lowerValue + 2000)
                            }
                    )
            }
        }
        .frame(height: thumbDiameter)
    }
}
