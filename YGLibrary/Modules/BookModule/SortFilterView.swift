//
//  SortFilterView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI
import Dependencies

// MARK: - SortableType Protocol
protocol SortableType: CaseIterable, Equatable {
    var displayText: String { get }
}

enum SearchSortType: String, CaseIterable, SortableType {
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

enum FavoriteSortType: String, CaseIterable, SortableType {
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

struct SortFilterView: View {
    @Dependency(\.router) private var router
    @ObservedObject var store: SearchListStore
    
    var body: some View {
        HStack(spacing: 12) {
            // 현재 정렬 상태 표시
            Text(store.sortType.displayText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 필터 버튼
            Button(action: {
                // 필터 기능 구현 예정
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
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
            
            // 정렬 버튼
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
            Text(store.state.sortType.displayText)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
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
struct SortBottomSheetView<SortType: SortableType>: View {
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
