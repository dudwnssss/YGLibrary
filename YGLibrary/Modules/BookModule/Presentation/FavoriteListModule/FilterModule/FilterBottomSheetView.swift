//
//  FilterBottomSheetView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/14/25.
//

import SwiftUI

import Dependencies

struct PriceFilterBottomSheetView: View {
    @State private var currentFilter: PriceFilter
    let onFilterSelected: (PriceFilter) -> Void
    @Dependency(\.router) private var router
    
    init(filter: PriceFilter, onFilterSelected: @escaping (PriceFilter) -> Void) {
        self._currentFilter = State(initialValue: filter)
        self.onFilterSelected = onFilterSelected
    }
    
    // 동적 프리셋 가격 범위들
    private var dynamicPresets: [(title: String, min: Int, max: Int)] {
        return currentFilter.generateDynamicPresets()
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            // 상단 핸들
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 24) {
                // 헤더
                HStack {
                    Text("가격 필터")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                    
                    Button("초기화") {
                        currentFilter = PriceFilter()
                        onFilterSelected(currentFilter)
                        router.dismiss(animated: true)
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 20)
                
                // 가격 범위 표시
                VStack(alignment: .leading, spacing: 16) {
                    Text("\(currentFilter.minPrice.formatted())원 ~ \(currentFilter.maxPrice.formatted())원")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                    
                    // 커스텀 슬라이더
                    VStack(spacing: 20) {
                        HStack {
                            Text("\(currentFilter.dynamicMinPrice.formatted()) 원")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(currentFilter.dynamicMaxPrice.formatted())원")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        YGRangeSlider(
                            minValue: Double(currentFilter.dynamicMinPrice),
                            maxValue: Double(currentFilter.dynamicMaxPrice),
                            lowerValue: Binding(
                                get: { Double(currentFilter.minPrice) },
                                set: { currentFilter.minPrice = Int($0) }
                            ),
                            upperValue: Binding(
                                get: { Double(currentFilter.maxPrice) },
                                set: { currentFilter.maxPrice = Int($0) }
                            )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    
                    // 프리셋 버튼들
                    VStack(spacing: 16) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                            ForEach(dynamicPresets, id: \.title) { preset in
                                Button(action: {
                                    currentFilter.minPrice = preset.min
                                    currentFilter.maxPrice = preset.max
                                    currentFilter.isEnabled = true
                                }) {
                                    Text(preset.title)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(isPresetSelected(preset) ? .blue : .primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(isPresetSelected(preset) ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 적용 버튼
                    VStack(spacing: 16) {
                        Button(action: {
                            currentFilter.isEnabled = true
                            onFilterSelected(currentFilter)
                            router.dismiss(animated: true)
                        }) {
                            Text("적용")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                Spacer(minLength: 20)
            }
            .frame(maxWidth: .infinity)
            .background(
                Color(UIColor.systemBackground)
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 20,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 20
                    ))
            )
            .presentationDragIndicator(.hidden)
        }
    }
    
    private func isPresetSelected(_ preset: (title: String, min: Int, max: Int)) -> Bool {
        return currentFilter.minPrice == preset.min && currentFilter.maxPrice == preset.max
    }
}

