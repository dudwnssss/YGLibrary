//
//  SortFilterView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI
import Dependencies

enum SearchSortType: String, CaseIterable {
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

enum FavoriteSortType {
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
                    to: .sortBottomSheet(store.sortType) { sort in
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

struct SortBottomSheetView: View {
    let selectedSort: SearchSortType
    let onSortSelected: (SearchSortType) -> Void
    @Dependency(\.router) private var router
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 헤더
            HStack {
                Text("정렬")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                Button("완료") {
                    router.dismiss(animated: true)
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
            }
            
            // 정렬 옵션들
            VStack(spacing: 0) {
                ForEach(SearchSortType.allCases, id: \.rawValue) { sort in
                    Button {
                        onSortSelected(sort)
                        router.dismiss(animated: true)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sort.displayText)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text(sort == .accuracy ? "관련성이 높은 순서" : "최근 출간된 순서")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if selectedSort == sort {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if sort != SearchSortType.allCases.last {
                        Divider()
                            .padding(.horizontal, 4)
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(UIColor.systemGray6))
            )
            
            Spacer()
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
    }
}