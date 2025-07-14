//
//  SortFilterView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI
import Dependencies

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
    var maxPrice: Int = 100000
    var isEnabled: Bool = false
    
    var dynamicMinPrice: Int = 0
    var dynamicMaxPrice: Int = 100000
    
    static let defaultMinPrice: Int = 0
    static let defaultMaxPrice: Int = 100000
    
    init(dynamicRange: (min: Int, max: Int)? = nil) {
        if let range = dynamicRange {
            self.dynamicMinPrice = range.min
            self.dynamicMaxPrice = range.max
            self.minPrice = range.min
            self.maxPrice = range.max
        } else {
            self.dynamicMinPrice = Self.defaultMinPrice
            self.dynamicMaxPrice = Self.defaultMaxPrice
            self.minPrice = Self.defaultMinPrice
            self.maxPrice = Self.defaultMaxPrice
        }
    }
    
    mutating func updateDynamicRange(min: Int, max: Int) {
        self.dynamicMinPrice = min
        self.dynamicMaxPrice = max
        
        if self.minPrice < min {
            self.minPrice = min
        }
        if self.maxPrice > max {
            self.maxPrice = max
        }
    }
    
    func apply(to books: [Book]) -> [Book] {
        guard isEnabled else { return books }
        
        return books.filter { book in
            let price = book.pricing.salePrice > 0 ? book.pricing.salePrice : book.pricing.originPrice
            return price >= minPrice && price <= maxPrice
        }
    }
    
    func generateDynamicPresets() -> [(title: String, min: Int, max: Int)] {
        let range = dynamicMaxPrice - dynamicMinPrice
        
        guard range > 20000 else {
            return [
                ("전체", dynamicMinPrice, dynamicMaxPrice)
            ]
        }
        
        let step = range / 4
        
        var presets: [(title: String, min: Int, max: Int)] = []
        
        let firstMax = roundToTenThousands(dynamicMinPrice + step)
        if dynamicMinPrice < firstMax {
            presets.append((
                title: "~\(formatPrice(firstMax))",
                min: dynamicMinPrice,
                max: firstMax
            ))
        }
        
        for i in 1..<3 {
            let rawMin = dynamicMinPrice + (step * i)
            let rawMax = dynamicMinPrice + (step * (i + 1))
            
            let roundedMin = roundToTenThousands(rawMin)
            let roundedMax = roundToTenThousands(rawMax)
            
            if roundedMin < roundedMax {
                presets.append((
                    title: "\(formatPrice(roundedMin))~\(formatPrice(roundedMax))",
                    min: roundedMin,
                    max: roundedMax
                ))
            }
        }
        
        let lastMin = roundToTenThousands(dynamicMinPrice + (step * 3))
        if lastMin < dynamicMaxPrice {
            presets.append((
                title: "\(formatPrice(lastMin))~",
                min: lastMin,
                max: dynamicMaxPrice
            ))
        }
        
        return presets
    }
    
    private func roundToTenThousands(_ price: Int) -> Int {
        if price < 10000 {
            return 10000
        }
        
        let remainder = price % 10000
        if remainder >= 5000 {
            return price + (10000 - remainder)
        } else {
            return price - remainder
        }
    }
    
    private func formatPrice(_ price: Int) -> String {
        if price >= 10000 {
            let manwon = price / 10000
            let remainder = price % 10000
            
            if remainder == 0 {
                return "\(manwon)만원"
            } else if remainder % 1000 == 0 {
                let cheonwon = remainder / 1000
                return "\(manwon)만\(cheonwon)천원"
            } else {
                let formatted = String(format: "%.1f", Double(price) / 10000.0)
                return "\(formatted)만원"
            }
        } else if price >= 1000 {
            let cheonwon = price / 1000
            return "\(cheonwon)천원"
        } else {
            return "\(price)원"
        }
    }
    
    var displayText: String {
        if !isEnabled {
            return "전체 가격"
        } else {
            return "\(minPrice.formatted())원 ~ \(maxPrice.formatted())원"
        }
    }
}

extension PriceFilter {
    static func calculatePriceRange(from books: [Book]) -> (min: Int, max: Int) {
        guard !books.isEmpty else {
            return (min: defaultMinPrice, max: defaultMaxPrice)
        }
        
        let prices = books.map { book in
            book.pricing.salePrice > 0 ? book.pricing.salePrice : book.pricing.originPrice
        }.filter { $0 > 0 }
        
        guard !prices.isEmpty else {
            return (min: defaultMinPrice, max: defaultMaxPrice)
        }
        
        let minPrice = prices.min() ?? defaultMinPrice
        let maxPrice = prices.max() ?? defaultMaxPrice
        
        let adjustedMax = Int(Double(maxPrice) * 1.1)
        let roundedMax = roundToTenThousands(adjustedMax)
        
        return (min: 0, max: roundedMax)
    }
    
    private static func roundToTenThousands(_ price: Int) -> Int {
        if price < 10000 {
            return 10000
        }
        
        let remainder = price % 10000
        if remainder >= 5000 {
            return price + (10000 - remainder)
        } else {
            return price - remainder
        }
    }
}

struct SearchSortView: View {
    @Dependency(\.router) private var router
    @ObservedObject var store: SearchListStore
    
    var body: some View {
        HStack(spacing: 12) {
            Text(store.sortType.displayText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            YGCapsuleButton.sortButton {
                router.navigate(
                    to: .searchSortBottomSheet(store.sortType) { sort in
                        store.dispatch(.sort(sort))
                    },
                    type: .present(style: .automatic)
                )
            }
        }
    }
}

struct FavoriteSortFilterView: View {
    @Dependency(\.router) private var router
    @ObservedObject var store: FavoriteListStore
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            YGCapsuleButton(
                icon: "slider.horizontal.3",
                title: "필터",
                hasBadge: store.state.priceFilter.isEnabled
            ) {
                router.navigate(
                    to: .priceFilterBottomSheet(store.state.priceFilter) { filter in
                        store.dispatch(.updatePriceFilter(filter))
                    },
                    type: .present(style: .automatic)
                )
            }
         
            YGCapsuleButton.sortButton {
                router.navigate(
                    to: .favoriteSortBottomSheet(store.state.sortType) { sort in
                        store.dispatch(.sort(sort))
                    },
                    type: .present(style: .automatic)
                )
            }
        }
    }
}

struct SortBottomSheetView<SortType: Sortable>: View {
    let selectedSort: SortType
    let sortOptions: [SortType]
    let onSortSelected: (SortType) -> Void
    @Dependency(\.router) private var router
    
    var body: some View {
        VStack(spacing: .zero) {
            // 상단 핸들
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: .zero) {
                // 헤더
                HStack {
                    Text("정렬")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // 정렬 옵션들
                VStack(spacing: .zero) {
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
                            .padding(.vertical, 14)
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
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.hidden)
    }
}

