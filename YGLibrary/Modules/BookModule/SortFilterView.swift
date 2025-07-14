//
//  SortFilterView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI
import Dependencies

// MARK: - SortableType Protocol
protocol Sortable: CaseIterable, Equatable {
    var displayText: String { get }
}

enum SearchSortType: String, CaseIterable, Sortable {
    case accuracy
    case latest
    
    var displayText: String {
        switch self {
        case .accuracy:
            "정확도순"
        case .latest:
            "발간일순"
        }
    }
}

enum FavoriteSortType: String, CaseIterable, Sortable {
    case ascending
    case descending
    
    var displayText: String {
        switch self {
        case .ascending:
            "오름차순(제목)"
        case .descending:
            "내림차순(제목)"
        }
    }
}

struct PriceFilter: Equatable {
    var minPrice: Int = 0
    var maxPrice: Int = 50000
    var isEnabled: Bool = false
    
    static let defaultMinPrice = 0
    static let defaultMaxPrice = 50000
    
    var displayText: String {
        if !isEnabled {
            return "전체 가격"
        } else {
            return "\(minPrice.formatted())원 ~ \(maxPrice.formatted())원"
        }
    }
}

struct SearchSortView: View {
    @Dependency(\.router) private var router
    @ObservedObject var store: SearchListStore
    
    var body: some View {
        HStack(spacing: 12) {
            // 현재 정렬 상태 표시
            Text(store.sortType.displayText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 정렬 버튼만 표시 (필터 제거)
            Button(action: {
                router.navigate(
                    to: .searchSortBottomSheet(store.sortType) { sort in
                        store.dispatch(.sort(sort))
                    },
                    type: .present(style: .automatic)
                )
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .medium))
                    Text("정렬")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - FavoriteSortFilterView
struct FavoriteSortFilterView: View {
    @Dependency(\.router) private var router
    @ObservedObject var store: FavoriteListStore
    
    var body: some View {
        HStack(spacing: 12) {
            // 현재 정렬 상태 표시
            VStack(alignment: .leading, spacing: 2) {
                 Text(store.state.sortType.displayText)
                     .font(.system(size: 14, weight: .medium))
                     .foregroundColor(.secondary)
                 
                 if store.state.priceFilter.isEnabled {
                     Text(store.state.priceFilter.displayText)
                         .font(.system(size: 12, weight: .regular))
                         .foregroundColor(.blue)
                 }
             }
            Spacer()
            
            // 필터 버튼
             Button(action: {
                 router.navigate(
                     to: .priceFilterBottomSheet(store.state.priceFilter) { filter in
                         store.dispatch(.updatePriceFilter(filter))
                     },
                     type: .present(style: .automatic)
                 )
             }) {
                 HStack(spacing: 6) {
                     Image(systemName: "slider.horizontal.3")
                         .font(.system(size: 14, weight: .medium))
                     Text("필터")
                         .font(.system(size: 14, weight: .medium))
                 }
                 .foregroundColor(.primary)
                 .padding(.horizontal, 12)
                 .padding(.vertical, 6)
                 .overlay(alignment: .topTrailing) {
                     if store.state.priceFilter.isEnabled {
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
            
            // 정렬 버튼
            Button(action: {
                router.navigate(
                    to: .favoriteSortBottomSheet(store.state.sortType) { sort in
                        store.dispatch(.sort(sort))
                    },
                    type: .present(style: .automatic)
                )
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 14, weight: .medium))
                    Text("정렬")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}

// MARK: - Generic SortBottomSheetView
struct SortBottomSheetView<SortType: Sortable>: View {
    let selectedSort: SortType
    let sortOptions: [SortType]
    let onSortSelected: (SortType) -> Void
    @Dependency(\.router) private var router
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 핸들
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12) // 🔧 패딩 증가
                .padding(.bottom, 24) // 🔧 패딩 감소
            
            VStack(alignment: .leading, spacing: 0) {
                // 헤더
                HStack {
                    Text("정렬")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24) // 🔧 패딩 감소
                
                // 정렬 옵션들
                VStack(spacing: 0) {
                    ForEach(Array(sortOptions.enumerated()), id: \.offset) { index, sortType in
                        Button(action: {
                            onSortSelected(sortType)
                            router.dismiss(animated: true)
                        }) {
                            HStack(spacing: 16) {
                                Text(sortType.displayText)
                                    .font(.system(size: 17, weight: .regular))
                                    .foregroundColor(selectedSort == sortType ? .blue : .primary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if selectedSort == sortType {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14) // 🔧 패딩 감소
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if index < sortOptions.count - 1 {
                            Divider()
                                .padding(.leading, 20)
                        }
                    }
                }
            }
            
            Spacer(minLength: 20) // 🔧 최소 여백 감소
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
        .presentationDetents([.height(240)]) // 🔧 고정 높이로 변경
        .presentationDragIndicator(.hidden)
    }
}

struct PriceFilterBottomSheetView: View {
    @State private var currentFilter: PriceFilter
    let onFilterSelected: (PriceFilter) -> Void
    @Dependency(\.router) private var router
    
    init(filter: PriceFilter, onFilterSelected: @escaping (PriceFilter) -> Void) {
        self._currentFilter = State(initialValue: filter)
        self.onFilterSelected = onFilterSelected
    }
    
    // 프리셋 가격 범위들
    private let pricePresets: [(title: String, min: Int, max: Int)] = [
        ("1만원 이하", 0, 10000),
        ("1~2만원", 10000, 20000),
        ("2~3만원", 20000, 30000),
        ("3~4만원", 30000, 40000),
        ("4만원 이상", 40000, 50000)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
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
                            Text("\(PriceFilter.defaultMinPrice.formatted()) 원")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(PriceFilter.defaultMaxPrice.formatted())원")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 20)
                        
                        YGRangeSlider(
                            minValue: Double(PriceFilter.defaultMinPrice),
                            maxValue: Double(PriceFilter.defaultMaxPrice),
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
                            ForEach(pricePresets, id: \.title) { preset in
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

