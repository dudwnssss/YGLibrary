# YGLibrary

> 카카오 도서 검색 API를 활용한 iOS 도서 검색 및 즐겨찾기 관리 애플리케이션

## 📱 주요 기능

- **도서 검색**: 카카오 도서 검색 API를 통한 실시간 도서 검색
- **무한 스크롤**: 페이지네이션을 통한 대용량 검색 결과 처리
- **즐겨찾기 관리**: 로컬 데이터베이스를 활용한 도서 즐겨찾기 기능
- **정렬 및 필터링**: 정확도/최신순/가격순 정렬, 가격 범위 필터링
- **도서 상세 정보**: 상세 페이지에서 도서 정보 확인 및 즐겨찾기 관리

## 🛠 빌드 방법

### 요구사항
- **Xcode**: 16.2+
- **iOS Deployment Target**: 16.0+
- **Swift**: 5.0+

### 빌드 단계

1. **프로젝트 클론**
   ```bash
   git clone <repository-url>
   cd YGLibrary
   ```

2. **Xcode에서 프로젝트 열기**
   ```bash
   open YGLibrary.xcodeproj
   ```

3. **Swift Package Manager 의존성 해결**
   - Xcode에서 자동으로 의존성이 다운로드됩니다
   - 수동으로 해결하려면: File → Add Package Dependencies

4. **API 키 설정**
   ```swift
   // YGLibrary/Application/Secrets.swift 파일 생성
   enum Secrets {
       static let kakaoRestAPIKey = "YOUR_KAKAO_REST_API_KEY"
   }
   ```

5. **빌드 및 실행**
   - `Cmd + R`로 시뮬레이터에서 실행
   - 실제 기기에서 테스트 시 개발자 계정 설정 필요

## 📚 사용 프레임워크

### Apple Native Frameworks
- **SwiftUI**: 선언적 UI 프레임워크를 활용한 모던 iOS 개발
- **Combine**: 반응형 프로그래밍과 상태 관리
- **Foundation**: 기본 데이터 타입 및 유틸리티

### External Dependencies
- **[Dependencies](https://github.com/pointfreeco/swift-dependencies)** (1.9.2+)
  - Point-Free의 의존성 주입 프레임워크
  - 컴파일 타임 안전성과 테스트 용이성 제공
  
- **[GRDB](https://github.com/groue/GRDB.swift)** (master branch)
  - SQLite 데이터베이스 ORM
  - 타입 안전한 쿼리와 마이그레이션 지원
  
- **[Kingfisher](https://github.com/onevcat/Kingfisher)** (8.4.0+)
  - 이미지 다운로드, 캐싱, 표시를 위한 라이브러리
  - 메모리 및 디스크 캐싱으로 성능 최적화

## 🏗 프로젝트 구조

```
YGLibrary/
├── Application/                       # 앱 진입점 및 설정
│   ├── AppDelegate.swift             # 앱 생명주기 관리
│   ├── SceneDelegate.swift           # 씬 기반 UI 관리
│   └── Assets.xcassets              # 이미지 및 컬러 리소스
│
├── Modules/                          # 기능별 모듈화
│   ├── Store.swift                   # Store 프로토콜 정의
│   ├── MainTabModule/                # 메인 탭바 모듈
│   │   └── MainTabBarController.swift
│   └── BookModule/                   # 도서 관련 기능
│       ├── Domain/                   # 도메인 모델
│       │   └── Book.swift
│       └── Presentation/             # 프레젠테이션 레이어
│           ├── SearchListModule/     # 도서 검색 기능
│           ├── FavoriteListModule/   # 즐겨찾기 관리
│           ├── BookDetailModule/     # 도서 상세 정보
│           └── SubViews/             # 공통 UI 컴포넌트
│
├── Services/                         # 데이터 레이어
│   ├── Network/                      # 네트워크 서비스
│   │   ├── Services/                 # 비즈니스 로직
│   │   ├── Request/                  # API 요청 모델
│   │   ├── DataMapping/              # DTO ↔ Domain 변환
│   │   └── NetworkLogger.swift       # 네트워크 디버깅
│   └── Database/                     # 로컬 데이터베이스
│       ├── DatabaseService.swift     # GRDB 설정 및 관리
│       ├── Repositories/             # Repository 패턴
│       └── DataMapping/              # DB ↔ Domain 변환
│
└── Common/                           # 공통 모듈
    ├── Router.swift                  # 네비게이션 관리
    ├── Components/                   # 재사용 가능한 UI
    ├── Extensions/                   # Swift 타입 확장
    ├── Constants/                    # 상수 정의
    └── Utils/                        # 유틸리티 함수
```

## 🎯 주요 구현 포인트

### 1. Store Pattern (TCA 영감)

**핵심 구현**
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

**특징**
- `@dynamicMemberLookup`을 통한 상태 접근 간소화 (`store.books` 대신 `store.state.books`)
- 타입 안전한 Action 기반 상태 변경
- SwiftUI `@ObservableObject`와 완벽 호환
- 단방향 데이터 플로우로 예측 가능한 상태 관리

### 2. Dependency Injection System

**Dependencies 라이브러리 활용**
```swift
@Dependency(\.router) private var router
@Dependency(\.bookService) private var bookService
@Dependency(\.favoriteService) private var favoriteService
```

**장점**
- 컴파일 타임 의존성 해결로 런타임 에러 방지
- 테스트용 Mock 객체 간편한 주입
- 프로토콜 기반 추상화로 느슨한 결합

### 3. Repository Pattern + GRDB

**Repository 인터페이스**
```swift
protocol BookRepository {
    func getFavoriteBooks() async throws -> [Book]
    func addToFavorites(_ book: Book) async throws
    func removeFromFavorites(isbn: String) async throws
    func isFavorite(isbn: String) async throws -> Bool
}
```

**구현 특징**
- 데이터 소스 추상화로 테스트 용이성 향상
- GRDB의 타입 안전한 쿼리 빌더 활용
- async/await 기반 현대적 비동기 처리
- 컴파일 타임 SQL 검증

### 4. 무한 스크롤 최적화

**핵심 로직**
```swift
case .bookAppeared(let book):
    guard state.canLoadMore,
          book.isbn == state.books.last?.isbn,
          state.lastTriggeredISBN != book.isbn else { return }
    
    await loadNextPage()
```

**최적화 포인트**
- 중복 요청 방지 메커니즘
- 마지막 아이템 감지를 통한 자동 로딩
- 로딩 상태 관리로 UI 플리커링 방지
- 메모리 효율적인 페이지네이션

### 5. 고유 ID 생성 시스템

**중복 제거 로직**
```swift
private static func generateUniqueId(
    isbn: String, 
    title: String, 
    publisher: String, 
    dateTime: Date?, 
    url: String
) -> String {
    let dateString = dateTime?.ISO8601Format() ?? ""
    let combinedString = "\(isbn)_\(title)_\(publisher)_\(dateString)_\(url)"
    return combinedString.data(using: .utf8)?.base64EncodedString() ?? UUID().uuidString
}
```

**특징**
- 복합 키 기반 고유 ID 생성
- API 응답의 중복 도서 자동 필터링
- Base64 인코딩으로 안전한 ID 생성

### 6. 네트워크 로깅 시스템

**구조화된 로깅**
```swift
struct NetworkLogger {
    static func log(request: URLRequest) {
        // 📤 REQUEST 정보 포맷팅
    }
    
    static func log(response: URLResponse?, data: Data?, error: Error?) {
        // 📥 RESPONSE 정보 포맷팅
    }
}
```

**기능**
- 요청/응답 정보 상세 로깅
- Authorization 헤더 자동 마스킹
- JSON 응답 예쁘게 포맷팅
- 디버깅 효율성 극대화

### 7. 중앙화된 네비게이션 관리

**Router 시스템**
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

**특징**
- 타입 안전한 네비게이션 목적지
- 다양한 프레젠테이션 스타일 지원
- 중앙화된 화면 전환 로직
- SwiftUI + UIKit 하이브리드 지원

### 8. 고급 필터링 시스템

**가격 필터 구현**
```swift
struct PriceFilter {
    var minPrice: Int = 0
    var maxPrice: Int = 100000
    var isEnabled: Bool = false
    
    func apply(to books: [Book]) -> [Book] {
        guard isEnabled else { return books }
        return books.filter { book in
            let price = book.pricing.salePrice > 0 ? 
                       book.pricing.salePrice : book.pricing.originPrice
            return price >= minPrice && price <= maxPrice
        }
    }
}
```

**특징**
- 판매가 우선, 정가 대체 로직
- 실시간 필터링 적용
- 범위 슬라이더 UI 통합

## 🧪 테스트 고려사항

### 아키텍처적 테스트 용이성
- **의존성 주입**: Mock 객체를 통한 격리된 단위 테스트
- **Store Pattern**: 상태 변화 로직의 독립적 테스트
- **Repository Pattern**: 데이터 레이어 추상화로 테스트 더블 활용

### 테스트 환경 구성
```swift
// 테스트용 의존성 설정 예시
extension DependencyValues {
    var bookService: BookService {
        get { self[BookServiceKey.self] }
        set { self[BookServiceKey.self] = newValue }
    }
}

// Mock 서비스 주입
withDependencies {
    $0.bookService = MockBookService()
} operation: {
    // 테스트 실행
}
```

## 🚀 기술적 특징

### 성능 최적화
- **LazyVStack**: 대용량 리스트 렌더링 최적화
- **Kingfisher**: 이미지 메모리/디스크 캐싱
- **중복 제거**: 효율적인 메모리 사용
- **비동기 처리**: async/await 기반 논블로킹 UI

### 사용자 경험
- **실시간 검색**: 타이핑과 동시에 검색 결과 업데이트
- **스켈레톤 로딩**: 로딩 상태의 시각적 피드백
- **에러 핸들링**: 사용자 친화적 오류 메시지
- **접근성**: VoiceOver 지원 고려

### 코드 품질
- **타입 안전성**: 컴파일 타임 에러 검출
- **모듈화**: 기능별 분리된 아키텍처
- **확장성**: 새로운 기능 추가 용이
- **유지보수성**: 명확한 책임 분리

## 📝 프로젝트 정보

- **개발 기간**: 약 1주
- **개발자**: 임영준
- **프로젝트 유형**: 과제전형용 포트폴리오
- **라이선스**: MIT License

---

*이 프로젝트는 현대적인 iOS 개발 패턴과 최신 기술 스택을 활용하여 확장 가능하고 유지보수가 용이한 앱 아키텍처를 구현한 샘플 프로젝트입니다.*