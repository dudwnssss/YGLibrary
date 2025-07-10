//
//  BookDetailView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

class CustomToolbarStorage: ObservableObject {
    @Published var items: [CustomToolbarItem] = []
}

struct CustomToolbarItem: Identifiable {
    let id = UUID()
    let placement: CustomToolbarPlacement
    let content: AnyView
    
    init<Content: View>(placement: CustomToolbarPlacement, @ViewBuilder content: () -> Content) {
        self.placement = placement
        self.content = AnyView(content())
    }
}

enum CustomToolbarPlacement {
    case leading
    case principal
    case trailing
}

struct CustomNavigationBar: View {
    @EnvironmentObject var toolbarStorage: CustomToolbarStorage
    var height: CGFloat
    
    init(height: CGFloat = 56) {
        self.height = height
    }
    
    private var leadingItems: [CustomToolbarItem] {
        toolbarStorage.items.filter { $0.placement == .leading }
    }
    
    private var principalItems: [CustomToolbarItem] {
        toolbarStorage.items.filter { $0.placement == .principal }
    }
    
    private var trailingItems: [CustomToolbarItem] {
        toolbarStorage.items.filter { $0.placement == .trailing }
    }
    
    var body: some View {
        ZStack {
            // Principal items - 항상 가운데 고정
            HStack {
                ForEach(principalItems) { item in
                    item.content
                }
            }
            
            // Leading과 Trailing items
            HStack {
                // Leading items
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

// 커스텀 툴바 Modifier
struct CustomToolbarModifier: ViewModifier {
    @EnvironmentObject var toolbarStorage: CustomToolbarStorage  // 기존 환경 객체 사용
    let items: [CustomToolbarItem]
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                toolbarStorage.items = items
            }
    }
}

// View Extension
extension View {
    func customToolbar(@CustomToolbarBuilder items: () -> [CustomToolbarItem]) -> some View {
        self.modifier(CustomToolbarModifier(items: items()))
    }
}

// Result Builder
@resultBuilder
struct CustomToolbarBuilder {
    static func buildBlock(_ components: CustomToolbarItem...) -> [CustomToolbarItem] {
        components
    }
}

struct CustomNavigationView<Content: View>: View {
    @StateObject private var toolbarStorage = CustomToolbarStorage()
    let content: Content
    var navigationBarHeight: CGFloat
    
    init(navigationBarHeight: CGFloat = 56, @ViewBuilder content: () -> Content) {
        self.navigationBarHeight = navigationBarHeight
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBar(height: navigationBarHeight)
                .environmentObject(toolbarStorage)
            content
                .environmentObject(toolbarStorage)
        }
        .navigationBarHidden(true)
    }
}

struct BookDetailView: View {
    var body: some View {
        CustomNavigationView {
            VStack(alignment: .leading) {
                Text("도서 제목")
                    .bold()
                    .font(.title2)
                HStack(alignment: .top, spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .aspectRatio(1.4/2, contentMode: .fit)
                        .foregroundStyle(
                            Color(uiColor: .systemGray5)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    Color(.systemGray3),
                                    lineWidth: 1
                                )
                        )
                    VStack(alignment: .leading) {
                        Text("저자 : ")
                            .bold()
                        +
                        Text("저자")
                        Text("출판사 : ")
                            .bold()
                        +
                        Text("출판사")
                        Text("출간일 : ")
                            .bold()
                        +
                        Text("출간일")
                        Text("isbn : ")
                            .bold()
                        +
                        Text("isbn")
                        Text("정상가 : ")
                            .bold()
                        +
                        Text("N원")
                        Text("할인가 : ")
                            .bold()
                        +
                        Text("N원")
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                Text("책 소개")
                    .bold()
                    .font(.headline)
                Spacer()
            }
            .customToolbar {
                CustomToolbarItem(placement: .leading) {
                    Image(systemName: "arrow.left")
                }
                CustomToolbarItem(placement: .trailing) {
                    Image(systemName: "heart")
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    BookDetailView()
}

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
