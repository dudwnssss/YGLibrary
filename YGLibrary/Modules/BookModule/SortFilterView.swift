//
//  SortFilterView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

enum SearchSortType: String {
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
        Button(action: {
            
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
            
#Preview {
    SortFilterView()
}




