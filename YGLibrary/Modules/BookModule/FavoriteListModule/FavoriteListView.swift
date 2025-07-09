//
//  FavoriteListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct FavoriteListView: View {
    var body: some View {
        NavigationStack {
            VStack {
                SearchBarView()
                    .padding(.horizontal, 16)
                SortFilterView()
                Spacer()
            }
            .navigationTitle("즐겨찾기")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    FavoriteListView()
}
