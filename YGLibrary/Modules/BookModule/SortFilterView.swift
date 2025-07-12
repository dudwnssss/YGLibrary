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
    private let placeholder: String = "제목 또는 저자를 입력하세요"
    
    var body: some View {
        HStack {
            Text("오름차순")
            Spacer()
            filterButton
            sortButton
        }
        .padding(.horizontal, 16)
        .frame(height: 60)
    }
    
    private var filterButton: some View {
        Button(action: {
            
        }) {
            HStack {
                Image(systemName: "slider.horizontal.3")
                Text("필터")
            }
            .padding(.horizontal, 8)
            .frame(height: 32)
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 1)
            }
        }
    }
    
    private var sortButton: some View {
        Button(
            action: {
                router.navigate(
                    to: .sortBottomSheet(store.sortType) { sort in
                        store.dispatch(.sort(sort))
                    },
                    type: .present(style: .automatic))
            }) {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text("정렬")
                }
                .padding(.horizontal, 8)
                .frame(height: 32)
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(lineWidth: 1)
                }
            }
    }
}

struct SortBottomSheetView: View {
    let selectedSort: SearchSortType
    let onSortSelected: (SearchSortType) -> Void
    @Dependency(\.router) private var router
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("정렬")
                .font(.headline)
            ForEach(SearchSortType.allCases, id: \.rawValue) { sort in
                Button {
                    onSortSelected(sort)
                    router.dismiss(animated: true)
                } label: {
                    HStack {
                        Text(sort.displayText)
                        Spacer()
                        if selectedSort == sort {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(YGScaleButtonStyle())
            }
        }
        .padding(.horizontal, 16)
    }
}
