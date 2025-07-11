//
//  SearchListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct SearchListView: View {
    var body: some View {
        YGNavigationView {
            VStack {
                SearchBarView()
                    .padding(.horizontal, 16)
                SortFilterView()
                Spacer()
            }
            .ygToolBar {
                YGToolbarItem(placement: .principal) {
                    Text("검색")
                }
            }
        }
    }
}

#Preview {
    SearchListView()
}

