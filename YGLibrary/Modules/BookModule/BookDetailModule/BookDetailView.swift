//
//  BookDetailView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

import Dependencies

struct BookDetailView: View {
    @Dependency(\.router) private var router
    
    var body: some View {
        YGNavigationView {
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
            .ygToolBar {
                YGToolbarItem(placement: .leading) {
                    Button(action: {
                        router.pop(animated: true)
                    }) {
                        Image(systemName: "arrow.left")
                    }
                }
                YGToolbarItem(placement: .trailing) {
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


