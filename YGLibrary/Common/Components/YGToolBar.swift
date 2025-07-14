//
//  YGToolBar.swift
//  YGLibrary
//
//  Created by 임영준 on 7/11/25.
//

import SwiftUI

enum YGToolbarPlacement {
    case leading
    case principal
    case trailing
}

struct YGToolbarItem {
    let placement: YGToolbarPlacement
    let content: AnyView
    
    init<Content: View>(placement: YGToolbarPlacement, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.content = AnyView(content())
    }
}

@resultBuilder
struct YGToolbarContentBuilder {
    static func buildBlock(_ items: YGToolbarItem...) -> [YGToolbarItem] {
        items
    }
    
    static func buildOptional(_ item: YGToolbarItem?) -> YGToolbarItem? {
        item
    }
    
    static func buildEither(first item: YGToolbarItem) -> YGToolbarItem {
        item
    }
    
    static func buildEither(second item: YGToolbarItem) -> YGToolbarItem {
        item
    }
    
    static func buildArray(_ items: [YGToolbarItem]) -> [YGToolbarItem] {
        items
    }
    
    static func buildExpression(_ item: YGToolbarItem) -> YGToolbarItem {
        item
    }
    
    static func buildExpression<Content: View>(_ content: Content) -> YGToolbarItem {
        YGToolbarItem(placement: .trailing) { content }
    }
}

struct YGToolbar: View {
    let height: CGFloat
    let items: [YGToolbarItem]
    
    private var leadingItems: [YGToolbarItem] {
        items.filter { $0.placement == .leading }
    }
    
    private var principalItems: [YGToolbarItem] {
        items.filter { $0.placement == .principal }
    }
    
    private var trailingItems: [YGToolbarItem] {
        items.filter { $0.placement == .trailing }
    }
    
    var body: some View {
        ZStack {
            // Principal (중앙)
            HStack(spacing: 8) {
                ForEach(principalItems.indices, id: \.self) { index in
                    principalItems[index].content
                }
            }
            
            // Leading과 Trailing
            HStack {
                // Leading
                HStack(spacing: 8) {
                    ForEach(leadingItems.indices, id: \.self) { index in
                        leadingItems[index].content
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Trailing
                HStack(spacing: 8) {
                    ForEach(trailingItems.indices, id: \.self) { index in
                        trailingItems[index].content
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .frame(height: height)
        .padding(.horizontal, 16)
        .background(Color(UIColor.systemBackground))
        .overlay(
            // 하단 구분선
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct YGToolbarModifier: ViewModifier {
    let height: CGFloat
    let items: [YGToolbarItem]
    
    func body(content: Content) -> some View {
        VStack(spacing: .zero) {
            YGToolbar(height: height, items: items)
            content
        }
        .navigationBarHidden(true)
    }
}

extension View {
    func ygToolbar(
        height: CGFloat = 44, // 🔧 시스템 네비게이션바와 같은 높이로 변경
        @YGToolbarContentBuilder content: () -> [YGToolbarItem]
    ) -> some View {
        modifier(YGToolbarModifier(height: height, items: content()))
    }
    
    func ygToolbar(
        height: CGFloat = 44, // 🔧 시스템 네비게이션바와 같은 높이로 변경
        @YGToolbarContentBuilder content: () -> YGToolbarItem
    ) -> some View {
        modifier(YGToolbarModifier(height: height, items: [content()]))
    }
}

extension YGToolbarItem {
    static func leading<Content: View>(@ViewBuilder content: () -> Content) -> YGToolbarItem {
        YGToolbarItem(placement: .leading, content: content)
    }
    
    static func principal<Content: View>(@ViewBuilder content: () -> Content) -> YGToolbarItem {
        YGToolbarItem(placement: .principal, content: content)
    }
    
    static func trailing<Content: View>(@ViewBuilder content: () -> Content) -> YGToolbarItem {
        YGToolbarItem(placement: .trailing, content: content)
    }
}
