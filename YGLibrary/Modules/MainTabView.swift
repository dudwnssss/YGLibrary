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
            Tab("검색", systemImage: "magnifyingglass") {
                SearchListView()
            }
            Tab("즐겨찾기", systemImage: "heart.fill") {
                SearchListView()
            }
        }
    }
}

#Preview {
    MainTabView()
}

struct SearchListView: View {
    var body: some View {
        VStack {
            
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("검색")
            }
        }
    }
}

struct FavoriteListView: View {
    var body: some View {
        VStack {
            
        }
    }
}
