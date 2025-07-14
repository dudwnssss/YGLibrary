# YGLibrary

iOS 도서 검색 및 즐겨찾기 관리 애플리케이션

## 📋 개요

카카오 도서 검색 API를 활용한 도서 검색 및 즐겨찾기 관리 앱입니다. TCA(The Composable Architecture)를 참고한 MVI Pattern을 적용하여 확장 가능하고 테스트 가능한 구조로 설계했습니다.

## 🛠 빌드 방법

### 요구사항
- **Swift**: 5.0
- **iOS**: 16.0+
- **Xcode**: 16.2

### 빌드 단계
1. 프로젝트 클론 후 Xcode로 열기
2. Swift Package Manager를 통한 의존성 자동 해결
3. API 키 설정 (카카오 REST API 키 필요)
4. 시뮬레이터 또는 실제 기기에서 빌드 및 실행

### API 키 설정
`YGLibrary/Application/Secrets.swift` 파일 생성 후 다음 내용 추가:
```swift
enum Secrets {
    static let kakaoRestAPIKey = "YOUR_KAKAO_REST_API_KEY"
}
```

## 📚 사용 프레임워크

### Apple Frameworks
- **SwiftUI**: 메인 UI 프레임워크
- **UIKit**: 탭바, 네비게이션 등 일부 UI 구성요소
- **Combine**: 리액티브 프로그래밍 및 상태 관리

### Third-party Libraries
- **[Dependencies](https://github.com/pointfreeco/swift-dependencies)** (1.0.0+): 의존성 주입 프레임워크
- **[GRDB](https://github.com/groue/GRDB.swift)** (6.0.0+): SQLite 데이터베이스 ORM
- **[Kingfisher](https://github.com/onevcat/Kingfisher)** (7.0.0+): 이미지 캐싱 및 비동기 로딩

## 🏗 프로젝트 구조

```
YGLibrary/
├── Application/                    # 앱 진입점 및 설정
│   ├── AppDelegate.swift          # 앱 델리게이트
│   ├── SceneDelegate.swift        # 씬 델리게이트 (네비게이션 초기화)
│   └── Assets.xcassets           # 이미지 및 컬러 에셋
│
├── Modules/                       # 기능별 모듈 (Clean Architecture)
│   ├── Store.swift               # Store 프로토콜 정의
│   ├── MainTabModule/            # 메인 탭바 모듈
│   └── BookModule/               # 도서 관련 기능 모듈
│       ├── SearchListModule/     # 도서 검색 (Store + View)
│       ├── FavoriteListModule/   # 즐겨찾기 관리 (Store + View)
│       ├── BookDetailModule/     # 도서 상세 정보 (Store + View)
│       └── SubModules/           # 공통 UI 컴포넌트
│           ├── BookRowView.swift
│           ├── SearchBarView.swift
│           └── SortFilterView.swift
│
├── Services/                      # 데이터 레이어
│   ├── Network/                  # 네트워크 서비스
│   │   ├── NetworkLogger.swift   # 네트워크 요청/응답 로깅
│   │   ├── Request/              # API 요청 모델
│   │   ├── Services/             # 서비스 구현체
│   │   └── DataMapping/          # DTO → Domain 모델 변환
│   └── Database/                 # 로컬 데이터베이스
│       ├── DatabaseService.swift # GRDB 설정 및 관리
│       ├── Repositories/         # Repository 패턴 구현
│       └── DataMapping/          # DB ↔ Domain 모델 변환
│
└── Common/                       # 공통 모듈
    ├── Router.swift              # 네비게이션 관리
    ├── ModuleFactory.swift       # 뷰 컨트롤러 팩토리
    ├── Components/               # 재사용 가능한 UI 컴포넌트
    ├── Extensions/               # Swift 타입 확장
    ├── Constants/                # 상수 정의
    └── Utils/                    # 유틸리티 함수
```

## 🎯 주요 구현 포인트

### 1. Store Pattern (TCA 패턴 참고)
```swift
@dynamicMemberLookup
@MainActor
protocol Store: ObservableObject {
    associatedtype Action
    associatedtype State
    
    var state: State { get }
    func dispatch(_ action: Action)
}
```

**구현 특징:**
- `@dynamicMemberLookup`을 활용한 상태 접근 간소화
- 타입 안전한 Action 기반 상태 변경
- SwiftUI의 `@ObservableObject`와 완벽 호환
- 단방향 데이터 플로우로 예측 가능한 상태 관리

### 2. Dependency Injection (Dependencies 라이브러리)
```swift
@Dependency(\.router) private var router
@Dependency(\.bookService) private var bookService
@Dependency(\.favoriteService) private var favoriteService
```

**구현 특징:**
- 컴파일 타임 의존성 해결
- 테스트용 Mock 객체 쉬운 주입
- 런타임 에러 없는 안전한 의존성 관리

### 3. Repository Pattern + GRDB
```swift
protocol BookRepository {
    func getFavoriteBooks() async throws -> [Book]
    func addToFavorites(_ book: Book) async throws
    func removeFromFavorites(isbn: String) async throws
    func isFavorite(isbn: String) async throws -> Bool
}
```

**구현 특징:**
- 데이터 소스 추상화로 테스트 용이성 향상
- GRDB의 타입 안전한 쿼리 빌더 활용
- async/await 기반 비동기 처리

### 4. 무한 스크롤 구현
```swift
// SearchListStore 내부
case .bookAppeared(let book):
    guard state.canLoadMore,
          book.isbn == state.books.last?.isbn,
          state.lastTriggeredISBN != book.isbn else { return }
    
    await loadNextPage()
```

**구현 특징:**
- 중복 요청 방지 로직
- 마지막 아이템 감지를 통한 자동 로딩
- 페이지네이션 상태 관리

### 5. 커스텀 네트워크 로거
```swift
struct NetworkLogger {
    static func log(request: URLRequest) {
        // 요청 정보 포맷팅 및 출력
    }
    
    static func log(response: URLResponse?, data: Data?, error: Error?) {
        // 응답 정보 포맷팅 및 출력
    }
}
```

**구현 특징:**
- 요청/응답 정보 상세 로깅
- Authorization 헤더 마스킹 처리
- JSON 응답 예쁘게 출력

### 6. 중앙화된 네비게이션 관리
```swift
enum NavigationType {
    case push
    case present(style: UIModalPresentationStyle = .automatic)
    case fullScreenPresent
    case setRoot
}

protocol Router {
    func navigate(to: Destination, type: NavigationType)
    func pop(animated: Bool)
    func dismiss(animated: Bool)
}
```

**구현 특징:**
- 타입 안전한 네비게이션
- 다양한 프레젠테이션 스타일 지원
- 중앙화된 화면 전환 로직

### 7. 가격 필터링 기능
```swift
struct PriceFilter {
    var minPrice: Int = 0
    var maxPrice: Int = 100000
    var isEnabled: Bool = false
    
    func apply(to books: [Book]) -> [Book] {
        guard isEnabled else { return books }
        return books.filter { book in
            let price = book.salePrice > 0 ? book.salePrice : book.price
            return price >= minPrice && price <= maxPrice
        }
    }
}
```

**구현 특징:**
- 판매가 우선, 정가 대체 로직
- 실시간 필터링 적용
- 범위 슬라이더를 통한 직관적 UI

## 🔧 기술적 특징

### 아키텍처
- **Clean Architecture**: 계층별 관심사 분리
- **MVVM + Store Pattern**: 단방향 데이터 플로우
- **Repository Pattern**: 데이터 소스 추상화

### 반응형 프로그래밍
- **Combine**: Publisher/Subscriber 패턴으로 데이터 스트림 관리
- **@Published**: 상태 변경 자동 감지 및 UI 업데이트

### 성능 최적화
- **Kingfisher**: 이미지 메모리/디스크 캐싱
- **LazyVStack**: 대용량 리스트 최적화
- **중복 제거**: ISBN 기반 중복 도서 필터링

### 에러 처리
- **Result Type**: 성공/실패 케이스 명시적 처리
- **Toast 시스템**: 사용자 친화적 에러 메시지
- **Graceful Degradation**: 네트워크 오류 시 적절한 대체 동작

## 🧪 테스트 고려사항

### 의존성 주입을 통한 테스트 용이성
```swift
extension DependencyValues {
    var bookService: BookService {
        get { self[BookServiceKey.self] }
        set { self[BookServiceKey.self] = newValue }
    }
}
```

### Mock 객체 활용
- 네트워크 서비스 Mock으로 단위 테스트 가능
- 데이터베이스 인메모리 테스트 환경 구성 가능
- Store 로직 독립적 테스트 가능

