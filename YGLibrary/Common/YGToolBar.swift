//
//  YGToolBar.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import SwiftUI

class YGToolbarStorage: ObservableObject {
    @Published var items: [YGToolbarItem] = []
}

struct YGToolbarItem: Identifiable {
    let id = UUID()
    let placement: YGToolbarPlacement
    let content: AnyView
    
    init<Content: View>(placement: YGToolbarPlacement, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.content = AnyView(content())
    }
}

enum YGToolbarPlacement {
    case leading
    case principal
    case trailing
}

struct YGNavigationBar: View {
    @EnvironmentObject var toolbarStorage: YGToolbarStorage
    var height: CGFloat
    
    init(height: CGFloat = 56) {
        self.height = height
    }
    
    private var leadingItems: [YGToolbarItem] {
        toolbarStorage.items.filter { $0.placement == .leading }
    }
    
    private var principalItems: [YGToolbarItem] {
        toolbarStorage.items.filter { $0.placement == .principal }
    }
    
    private var trailingItems: [YGToolbarItem] {
        toolbarStorage.items.filter { $0.placement == .trailing }
    }
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(principalItems) { item in
                    item.content
                }
            }
            
            HStack {
                HStack {
                    ForEach(leadingItems) { item in
                        item.content
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Trailing items
                HStack {
                    ForEach(trailingItems) { item in
                        item.content
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(height: height)
        .padding(.horizontal, 16)
        .background(Color.white)
    }
}

struct YGToolbarModifier: ViewModifier {
    @EnvironmentObject var toolbarStorage: YGToolbarStorage
    let items: [YGToolbarItem]
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                toolbarStorage.items = items
            }
    }
}

extension View {
    func ygToolBar(@YGToolbarBuilder items: () -> [YGToolbarItem]) -> some View {
        self.modifier(YGToolbarModifier(items: items()))
    }
}

@resultBuilder
struct YGToolbarBuilder {
    static func buildBlock(_ components: YGToolbarItem...) -> [YGToolbarItem] {
        components
    }
}

struct YGNavigationView<Content: View>: View {
    @StateObject private var toolbarStorage = YGToolbarStorage()
    let content: Content
    var navigationBarHeight: CGFloat
    
    init(navigationBarHeight: CGFloat = 56, @ViewBuilder content: () -> Content) {
        self.navigationBarHeight = navigationBarHeight
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            YGNavigationBar(height: navigationBarHeight)
                .environmentObject(toolbarStorage)
            content
                .environmentObject(toolbarStorage)
        }
        .navigationBarHidden(true)
    }
}
