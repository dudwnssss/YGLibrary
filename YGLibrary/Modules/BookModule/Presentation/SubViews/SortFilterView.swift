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
    
    // 동적 범위 설정을 위한 프로퍼티
    var dynamicMinPrice: Int = 0
    var dynamicMaxPrice: Int = 100000
    
    // 기본 고정값 (fallback용)
    static let defaultMinPrice: Int = 0
    static let defaultMaxPrice: Int = 100000
    
    // 동적 범위 기반 초기화
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
    
    // 가격 범위 업데이트
    mutating func updateDynamicRange(min: Int, max: Int) {
        self.dynamicMinPrice = min
        self.dynamicMaxPrice = max
        
        // 현재 선택된 범위가 새로운 동적 범위를 벗어나면 조정
        if self.minPrice < min {
            self.minPrice = min
        }
        if self.maxPrice > max {
            self.maxPrice = max
        }
    }
    
    // 필터 적용
    func apply(to books: [Book]) -> [Book] {
        guard isEnabled else { return books }
        
        return books.filter { book in
            let price = book.pricing.salePrice > 0 ? book.pricing.salePrice : book.pricing.originPrice
            return price >= minPrice && price <= maxPrice
        }
    }
    
    // 동적 프리셋 생성
    func generateDynamicPresets() -> [(title: String, min: Int, max: Int)] {
        let range = dynamicMaxPrice - dynamicMinPrice
        
        // 범위가 너무 작으면 기본 프리셋 사용
        guard range > 20000 else { // 최소 2만원 범위는 있어야 의미 있음
            return [
                ("전체", dynamicMinPrice, dynamicMaxPrice)
            ]
        }
        
        let step = range / 4 // 4개 구간으로 나누기
        
        var presets: [(title: String, min: Int, max: Int)] = []
        
        // 첫 번째 구간
        let firstMax = roundToTenThousands(dynamicMinPrice + step)
        if dynamicMinPrice < firstMax {
            presets.append((
                title: "~\(formatPrice(firstMax))",
                min: dynamicMinPrice,
                max: firstMax
            ))
        }
        
        // 중간 구간들
        for i in 1..<3 {
            let rawMin = dynamicMinPrice + (step * i)
            let rawMax = dynamicMinPrice + (step * (i + 1))
            
            let roundedMin = roundToTenThousands(rawMin)
            let roundedMax = roundToTenThousands(rawMax)
            
            // 중복되지 않도록 처리
            if roundedMin < roundedMax {
                presets.append((
                    title: "\(formatPrice(roundedMin))~\(formatPrice(roundedMax))",
                    min: roundedMin,
                    max: roundedMax
                ))
            }
        }
        
        // 마지막 구간
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
    
    // 만원 단위 반올림 헬퍼 메서드
    private func roundToTenThousands(_ price: Int) -> Int {
        // 만원 미만은 만원으로 올림
        if price < 10000 {
            return 10000
        }
        
        // 만원 단위로 반올림
        let remainder = price % 10000
        if remainder >= 5000 {
            return price + (10000 - remainder) // 올림
        } else {
            return price - remainder // 내림
        }
    }
    
    // 가격 포맷팅 (세밀한 조작과 깔끔한 표시 모두 지원)
    private func formatPrice(_ price: Int) -> String {
        if price >= 10000 {
            let manwon = price / 10000
            let remainder = price % 10000
            
            if remainder == 0 {
                return "\(manwon)만원"
            } else if remainder % 1000 == 0 {
                // 천원 단위로 떨어지는 경우 (ex: 15,000원 = 1만5천원)
                let cheonwon = remainder / 1000
                return "\(manwon)만\(cheonwon)천원"
            } else {
                // 소수점 표시
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

    // 가격 범위 계산을 위한 유틸리티
extension PriceFilter {
    // 책 목록에서 가격 범위 계산
    static func calculatePriceRange(from books: [Book]) -> (min: Int, max: Int) {
        guard !books.isEmpty else {
            return (min: defaultMinPrice, max: defaultMaxPrice)
        }
        
        let prices = books.map { book in
            book.pricing.salePrice > 0 ? book.pricing.salePrice : book.pricing.originPrice
        }.filter { $0 > 0 } // 0원인 책은 제외
        
        guard !prices.isEmpty else {
            return (min: defaultMinPrice, max: defaultMaxPrice)
        }
        
        let minPrice = prices.min() ?? defaultMinPrice
        let maxPrice = prices.max() ?? defaultMaxPrice
        
        // 최소값은 0에서 시작하고, 최대값은 약간의 여유를 둠
        let adjustedMax = Int(Double(maxPrice) * 1.1) // 10% 여유
        
        // 백원 단위 반올림으로 최소 만원 단위 적용
        let roundedMax = roundToTenThousands(adjustedMax)
        
        return (min: 0, max: roundedMax)
    }
    
    // 백원 단위 반올림하여 최소 만원 단위로 변환
    private static func roundToTenThousands(_ price: Int) -> Int {
        // 만원 미만은 만원으로 올림
        if price < 10000 {
            return 10000
        }
        
        // 만원 단위로 반올림
        let remainder = price % 10000
        if remainder >= 5000 {
            return price + (10000 - remainder) // 올림
        } else {
            return price - remainder // 내림
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
         
            // 정렬 버튼
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

// MARK: - Generic SortBottomSheetView
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
                .padding(.top, 12) // 🔧 패딩 증가
                .padding(.bottom, 24) // 🔧 패딩 감소
            
            VStack(alignment: .leading, spacing: .zero) {
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

