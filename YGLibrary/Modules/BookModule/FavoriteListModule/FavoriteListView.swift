//
//  FavoriteListView.swift
//  YGLibrary
//
//  Created by 임영준 on 7/9/25.
//

import SwiftUI

struct FavoriteListView: View {
    @State private var books: [Book] = [
        Book(
            title: "해리포터와 마법사의 돌",
            contents: "해리포터는 더즐리 가족과 함께 살고 있는 평범한 소년이었다. 그런데 열한 번째 생일을 맞아 자신이 마법사라는 사실을 알게 되고, 호그와트 마법학교에 입학하게 된다. 그곳에서 론과 헤르미온느를 만나 친구가 되고, 마법사의 돌을 둘러싼 모험을 시작한다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=1467038",
            isbn: "9788932473901",
            datetime: "",
            authors: ["J.K. 롤링"],
            publisher: "문학수첩",
            translators: ["김혜원"],
            price: 12000,
            sale_price: 10800,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F1467038",
            status: "정상판매"
        ),
        Book(
            title: "SwiftUI 완벽 가이드",
            contents: "SwiftUI는 애플의 새로운 UI 프레임워크로, 선언적 구문을 사용하여 사용자 인터페이스를 구축할 수 있습니다. 이 책은 SwiftUI의 기본 개념부터 고급 기능까지 단계별로 설명하며, 실제 앱 개발에 바로 적용할 수 있는 실용적인 예제를 제공합니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=5382910",
            isbn: "9791162245385",
            datetime: "",
            authors: ["김민수"],
            publisher: "한빛미디어",
            translators: [],
            price: 32000,
            sale_price: 28800,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5382910",
            status: "정상판매"
        ),
        Book(
            title: "클린 아키텍처",
            contents: "소프트웨어 아키텍처의 핵심 원칙과 실무 적용법을 다룬 로버트 마틴의 대표작입니다. 좋은 아키텍처란 무엇인지, 어떻게 설계해야 하는지에 대한 실용적인 가이드를 제공합니다. 개발자라면 반드시 읽어야 할 필독서입니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=4641823",
            isbn: "9788966262472",
            datetime: "",
            authors: ["로버트 C. 마틴"],
            publisher: "인사이트",
            translators: ["송준이"],
            price: 30000,
            sale_price: 27000,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4641823",
            status: "정상판매"
        ),
        Book(
            title: "이펙티브 자바",
            contents: "자바 플랫폼 설계자가 알려주는 자바 프로그래밍 기법의 모든 것. 자바를 더 효과적으로 사용하는 방법을 78개의 아이템으로 정리했습니다. 자바 개발자라면 반드시 알아야 할 핵심 내용들을 담고 있습니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=4982033",
            isbn: "9788966262281",
            datetime: "",
            authors: ["조슈아 블로크"],
            publisher: "인사이트",
            translators: ["이복연"],
            price: 36000,
            sale_price: 32400,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4982033",
            status: "정상판매"
        ),
        Book(
            title: "아토믹 해빗",
            contents: "1%의 작은 변화가 만드는 놀라운 결과에 대한 책입니다. 습관의 과학적 원리를 바탕으로 좋은 습관을 만들고 나쁜 습관을 버리는 실용적인 방법을 제시합니다. 전 세계적으로 베스트셀러가 된 자기계발서의 명작입니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=5234567",
            isbn: "9791162540329",
            datetime: "",
            authors: ["제임스 클리어"],
            publisher: "비즈니스북스",
            translators: ["이한이"],
            price: 16800,
            sale_price: 15120,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F5234567",
            status: "정상판매"
        ),
        Book(
            title: "코딩 인터뷰 완전 분석",
            contents: "구글, 마이크로소프트, 아마존 등 IT 대기업의 소프트웨어 개발자 면접을 준비하는 이들을 위한 필독서입니다. 189개의 프로그래밍 문제와 해답을 통해 코딩 면접을 체계적으로 준비할 수 있습니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=4521890",
            isbn: "9788966263079",
            datetime: "",
            authors: ["게일 라크만 맥도웰"],
            publisher: "한빛미디어",
            translators: ["이창현", "신명철"],
            price: 38000,
            sale_price: 34200,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F4521890",
            status: "정상판매"
        ),
        Book(
            title: "생각, 빠르고 느리게",
            contents: "노벨경제학상 수상자 대니얼 카너먼의 대표작으로, 인간의 두 가지 사고 시스템에 대해 설명합니다. 빠른 사고와 느린 사고의 특징을 이해하고, 더 나은 판단을 내리는 방법을 제시하는 심리학과 경제학의 걸작입니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=3456789",
            isbn: "9788934972464",
            datetime: "",
            authors: ["대니얼 카너먼"],
            publisher: "김영사",
            translators: ["이창신"],
            price: 25000,
            sale_price: 22500,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F3456789",
            status: "정상판매"
        ),
        Book(
            title: "1984",
            contents: "조지 오웰의 대표작으로, 전체주의 사회를 그린 디스토피아 소설입니다. 빅 브라더가 모든 것을 감시하는 사회에서 살아가는 윈스턴 스미스의 이야기를 통해 자유와 인권의 소중함을 일깨워주는 현대 문학의 고전입니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=2345678",
            isbn: "9788937460777",
            datetime: "",
            authors: ["조지 오웰"],
            publisher: "민음사",
            translators: ["정회성"],
            price: 13000,
            sale_price: 11700,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F2345678",
            status: "정상판매"
        ),
        Book(
            title: "데이터 사이언스 입문",
            contents: "파이썬을 활용한 데이터 분석의 기초부터 머신러닝까지 단계별로 학습할 수 있는 실용적인 가이드입니다. 실제 데이터를 활용한 프로젝트로 실무 경험을 쌓을 수 있습니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=6789012",
            isbn: "9791165213456",
            datetime: "",
            authors: ["박데이터"],
            publisher: "데이터북스",
            translators: [],
            price: 35000,
            sale_price: 31500,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F6789012",
            status: "정상판매"
        ),
        Book(
            title: "모던 자바스크립트",
            contents: "ES6부터 최신 자바스크립트까지 웹 개발자가 알아야 할 핵심 내용을 담았습니다. 실습 예제와 함께 자바스크립트의 현대적 기능들을 체계적으로 학습할 수 있습니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=7890123",
            isbn: "9791165214567",
            datetime: "",
            authors: ["김자바스크립트"],
            publisher: "웹북스",
            translators: [],
            price: 28000,
            sale_price: 25200,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F7890123",
            status: "정상판매"
        ),
        Book(
            title: "디자인 패턴",
            contents: "소프트웨어 설계의 고전으로 불리는 GoF의 디자인 패턴을 현대적 관점에서 재해석한 책입니다. 객체지향 프로그래밍의 핵심 원리를 이해하고 실무에 적용하는 방법을 제시합니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=8901234",
            isbn: "9788966263456",
            datetime: "",
            authors: ["에리히 감마", "리처드 헬름", "랄프 존슨", "존 블리시디스"],
            publisher: "인사이트",
            translators: ["김패턴"],
            price: 42000,
            sale_price: 37800,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F8901234",
            status: "정상판매"
        ),
        Book(
            title: "함수형 프로그래밍",
            contents: "함수형 프로그래밍의 핵심 개념과 실무 적용법을 다룬 실용서입니다. 불변성, 순수 함수, 고차 함수 등의 개념을 통해 더 안전하고 유지보수하기 쉬운 코드를 작성하는 방법을 학습합니다.",
            url: "https://search.daum.net/search?w=bookpage&bookId=9012345",
            isbn: "9791162245678",
            datetime: "",
            authors: ["이함수형"],
            publisher: "함수출판사",
            translators: [],
            price: 33000,
            sale_price: 29700,
            thumbnail: "https://search1.kakaocdn.net/thumb/R120x174.q85/?fname=http%3A%2F%2Ft1.daumcdn.net%2Flbook%2Fimage%2F9012345",
            status: "정상판매"
        )
    ]
    private let router = RouterImpl()
    
    var body: some View {
        YGNavigationView {
            VStack {
//                SearchBarView()
//                    .padding(.horizontal, 16)
//                SortFilterView()
                List(books) { book in
                    BookRowView(book: book) {
                        router.navigate(to: .bookDetail(book), type: .push)
                    } onLike: {
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(.init(top: 6, leading: 8, bottom: 6, trailing: 8))
                }
                .padding(.top, 6)
                .listStyle(PlainListStyle())
                .background(Color(uiColor: .systemGray5))
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
            .ygToolBar {
                YGToolbarItem(placement: .principal) {
                    Text("즐겨찾기")
                }
            }
//            .hideKeyboardOnTap()
        }
    }
}

#Preview {
    FavoriteListView()
}
