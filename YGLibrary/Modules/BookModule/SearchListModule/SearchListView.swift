//
//  SearchListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct SearchListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView()
                    .padding(.horizontal, 16)
                SortFilterView()
                Spacer()
            }
            .navigationTitle("검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    SearchListView()
}

