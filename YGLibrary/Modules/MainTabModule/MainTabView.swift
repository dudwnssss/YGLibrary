//
//  MainTabView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/8/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            SearchListView()
                .tabItem {
                    Text("검색")
                    Image(systemName: "magnifyingglass")
                }
            FavoriteListView()
                .tabItem {
                    Text("즐겨찾기")
                    Image(systemName: "heart.fill")
                }
        }
    }
}

#Preview {
    MainTabView()
}
