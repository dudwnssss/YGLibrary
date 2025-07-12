//
//  BookDetailView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

import Dependencies
import Kingfisher

struct BookDetailView: View {
    @Dependency(\.router) private var router
    let book: Book
    
    var body: some View {
        YGNavigationView {
            VStack(alignment: .leading) {
                Text(book.title)
                    .bold()
                    .font(.title2)
                HStack(alignment: .top, spacing: 8) {
                    KFImage(book.thumbnail)
                        .aspectRatio(1.4/2, contentMode: .fit)
                        .foregroundStyle(
                            Color(uiColor: .systemGray5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    VStack(alignment: .leading) {
                        Text("저자 : ")
                            .bold()
                        +
                        Text(book.authors.joined(separator: ", "))
                        Text("출판사 : ")
                            .bold()
                        +
                        Text(book.publisher)
                        Text("출간일 : ")
                            .bold()
                        +
                        Text("출간일")
                        Text("isbn : ")
                            .bold()
                        +
                        Text(book.isbn)
                        Text("정상가 : ")
                            .bold()
                        +
                        Text(book.pricing.displayOriginPrice)
                        Text("할인가 : ")
                            .bold()
                        +
                        Text(book.pricing.displaySalePrice)
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                    Spacer()
                }
                Text("책 소개")
                    .bold()
                    .font(.headline)
                Text(book.contents)
                Spacer()
            }
            .ygToolBar {
                YGToolbarItem(placement: .leading) {
                    Button(action: {
                        router.pop(animated: true)
                    }) {
                        Image(systemName: "arrow.left")
                    }
                    .buttonStyle(YGScaleButtonStyle())
                }
                YGToolbarItem(placement: .trailing) {
                    Image(systemName: "heart")
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

