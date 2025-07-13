//
//  BookRowView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

import Kingfisher

struct BookRowView: View {
    let book: Book
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            HStack(alignment: .top) {
                KFImage(book.thumbnail)
                    .aspectRatio(1.4/2, contentMode: .fit)
                    .foregroundStyle(.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading) {
                    Text("도서")
                        .font(.subheadline)
                        .bold()
                    Text(book.title)
                        .bold()
                        .font(.title3)
                    Text("출판사 : ")
                        .bold() +
                    Text(book.publisher)
                    Text("저자 : ")
                        .bold() +
                    Text("저자")
                    Spacer()
                }
                Spacer()
                VStack {
                    Button(action: {
                        onFavoriteToggle()
                    }) {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .foregroundStyle(isFavorite ? .red : .gray)
                            .padding(8)
                            .background(
                                Circle()
                                    .foregroundStyle(Color(uiColor: .systemGray6))
                            )
                    }
                    Spacer()
                    Text(book.pricing.displayOriginPrice)
                        .font(.title2)
                        .bold()
                }
            }
            .padding(8)
            .aspectRatio(3, contentMode: .fit)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

//#Preview {
//    let mockBook = Book(
//        title: "SwiftUI 완벽 가이드",
//        contents: "SwiftUI는 애플의 새로운 UI 프레임워크로, 선언적 구문을 사용하여 사용자 인터페이스를 구축할 수 있습니다. 이 책은 SwiftUI의 기본 개념부터 고급 기능까지 단계별로 설명하며, 실제 앱 개발에 바로 적용할 수 있는 실용적인 예제를 제공합니다.",
//        url: "https://search.daum.net/search?w=bookpage&bookId=5382910",
//        isbn: "9791162245385",
//        datetime: "",
//        authors: ["김민수"],
//        publisher: "한빛미디어",
//        translators: [],
//        price: 32000,
//        sale_price: 28800,
//        thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5382910",
//        status: "정상판매"
//    )
//    BookRowView(book: mockBook) {
//        
//    }
//}
