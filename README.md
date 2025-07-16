# 편의점 POS 시스템

Flutter로 개발된 편의점 POS(Point-of-Sale) 앱입니다. 바코드 스캔을 통해 상품을 장바구니에 추가하고, 다양한 프로모션 로직에 따라 결제 총액을 계산합니다.

## 주요 기능

### 1. 상품 관리
- 바코드 스캔 또는 수기 입력으로 상품 추가
- 장바구니 내 존재 시 수량 자동 증가
- 수량 조절 및 삭제 기능
- 상품 검색 기능

### 2. 프로모션 시스템
- **1+1 프로모션**: 같은 그룹 상품 2개 구매 시 2번째 상품 무료
- **2+1 프로모션**: 같은 그룹 상품 3개 구매 시 3번째 상품 무료
- **무료 증정**: 특정 상품 구매 시 특정 상품 1개 증정
- **고정 가격**: 프로모션 조건 만족 시 고정 가격 적용

### 3. 프로모션 파이프라인
- 추상화된 Promotion Pipeline 객체
- 모든 장바구니 항목은 파이프라인을 통과하여 최종 가격 계산
- 동적으로 프로모션 추가/제거 가능
- 다양한 타입의 프로모션 응답을 적절히 파싱하여 모델화

## 클린 아키텍처 구조

```
lib/
├── domain/                    # 도메인 레이어
│   ├── model/                 # 도메인 모델
│   │   ├── product.dart       # 상품 모델
│   │   ├── cart_item.dart     # 장바구니 아이템 모델
│   │   ├── promotion.dart     # 프로모션 모델 (sealed class)
│   │   └── model.dart         # 모델 export
│   ├── repository/            # 리포지토리 인터페이스
│   │   └── product_repository.dart
│   └── promotion/             # 프로모션 파이프라인
│       └── promotion_pipeline.dart
├── data/                      # 데이터 레이어
│   ├── model/                 # 데이터 모델
│   │   └── product_dto.dart   # Product DTO
│   ├── data_source/           # 데이터 소스
│   │   └── product_data_source.dart
│   └── repository/            # 리포지토리 구현
│       └── product_repository_impl.dart
└── presentation/              # 프레젠테이션 레이어
    ├── bloc/                  # 상태 관리
    │   └── cart_bloc.dart     # 장바구니 Bloc
    ├── pages/                 # 페이지
    │   └── pos_page.dart      # 메인 POS 페이지
    └── widgets/               # 위젯
        ├── cart_widget.dart   # 장바구니 위젯
        ├── product_list_widget.dart # 상품 목록 위젯
        └── barcode_scanner_widget.dart # 바코드 스캐너 위젯
```

## 실행 방법

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 앱 실행
```bash
flutter run
```

### 3. 코드 생성 (필요시)
```bash
flutter packages pub run build_runner build
```

## Mock 데이터

### 상품 데이터
앱은 다음과 같은 Mock 상품 데이터를 포함합니다:

| 카테고리 | 상품명 | 가격 | 프로모션 유형 | 그룹 |
|---------|--------|------|--------------|------|
| 음료수 | 코카콜라 500ml | 1,800원 | 1+1 | beverage |
| 음료수 | 스프라이트 500ml | 1,800원 | 1+1 | beverage |
| 커피 | 맥스웰하우스 커피 275ml | 1,200원 | 1+1 | coffee |
| 과자/스낵 | 스누피 초코바 | 1,500원 | 2+1 | snack |
| 생수 | 삼다수 2L | 1,200원 | 무료 증정 | water |
| 컵라면 | 농심 신라면 컵 | 1,100원 | 없음 | instant |
| 에너지드링크 | 레드불 250ml | 2,800원 | 고정 가격 | energy |

### 바코드 매핑
테스트용 바코드 매핑:
- `8801234567890` → 코카콜라 500ml
- `8801234567891` → 스프라이트 500ml
- `8801234567895` → 스누피 초코바
- `8801234567898` → 삼다수 2L
- `8801234567901` → 레드불 250ml

## 프로모션 파이프라인 설계

### Promotion Sealed Class
```dart
sealed class Promotion extends Equatable {
  String get type;
  String get group;
}

class BuyOneGetOnePromotion extends Promotion
class BuyTwoGetOnePromotion extends Promotion
class FreeGiftPromotion extends Promotion
class FixedPricePromotion extends Promotion
```

### 파이프라인 처리 순서
1. **1+1 프로모션**: 같은 그룹 상품 2개씩 묶어서 처리
2. **2+1 프로모션**: 같은 그룹 상품 3개씩 묶어서 처리
3. **무료 증정**: 특정 상품 구매 시 증정 상품 무료 처리
4. **고정 가격**: 프로모션 조건 만족 시 가격 강제 설정

### 프로모션 적용 로직
- 각 상품은 하나의 프로모션만 적용
- 증정 상품은 "증정됨"으로 표시
- 미증정 상태도 UI로 명확히 표시
- 동일 그룹 내 교차 증정 적용 가능

## UI 구성

### 필수 UI 기능
- 상품 입력 (스캔/입력)
- 장바구니 목록 표시
- 상품명, 수량, 개별 가격, 총 가격
- 증정 여부/미증정 여부 표시
- 프로모션 적용 상태 표시
- 결제 총액 표시

### 선택적 UI 기능
- 증정 상품 강조 표시
- 적용된 프로모션 정보 툴팁
- 프로모션 로그 트레이스

## 기술 스택

- **Flutter**: 크로스 플랫폼 UI 프레임워크
- **Flutter Bloc**: 상태 관리
- **Equatable**: 객체 비교
- **JSON Annotation**: JSON 직렬화
- **HTTP**: 네트워크 통신

## 개발 환경

- Flutter SDK: ^3.8.1
- Dart SDK: ^3.8.1
- Android/iOS 지원

## 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.
