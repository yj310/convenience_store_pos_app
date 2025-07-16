import 'package:flutter_test/flutter_test.dart';
import 'package:convenience_store_pos_app/domain/model/product.dart';
import 'package:convenience_store_pos_app/domain/model/cart_item.dart';
import 'package:convenience_store_pos_app/domain/model/promotion.dart';
import 'package:convenience_store_pos_app/domain/promotion/promotion_pipeline.dart';

void main() {
  group('편의점 POS 통합 테스트', () {
    late PromotionPipeline pipeline;
    late List<Product> products;

    setUp(() {
      pipeline = PromotionPipeline();
      products = [
        // 음료수 그룹 (1+1)
        const Product(
          id: 'cola',
          name: '코카콜라 500ml',
          category: '음료수',
          price: 1800,
          promotionType: '1+1',
          promotionGroup: 'beverage',
        ),
        const Product(
          id: 'sprite',
          name: '스프라이트 500ml',
          category: '음료수',
          price: 1800,
          promotionType: '1+1',
          promotionGroup: 'beverage',
        ),
        const Product(
          id: 'coffee',
          name: '맥스웰하우스 커피 275ml',
          category: '커피',
          price: 1200,
          promotionType: '1+1',
          promotionGroup: 'coffee',
        ),
        // 과자/스낵 그룹 (2+1)
        const Product(
          id: 'chocolate',
          name: '스누피 초코바',
          category: '과자/스낵',
          price: 1500,
          promotionType: '2+1',
          promotionGroup: 'snack',
        ),
        const Product(
          id: 'chips',
          name: '포카칩 오리지널',
          category: '과자/스낵',
          price: 1500,
          promotionType: '2+1',
          promotionGroup: 'snack',
        ),
        // 생수 (무료 증정)
        const Product(
          id: 'water',
          name: '삼다수 2L',
          category: '생수',
          price: 1200,
          promotionType: 'free_gift',
          promotionGroup: 'water',
        ),
        // 컵라면 (증정 대상)
        const Product(
          id: 'ramen1',
          name: '농심 신라면 컵',
          category: '컵라면',
          price: 1100,
          promotionType: null,
          promotionGroup: 'instant',
        ),
        // 에너지드링크 (고정 가격)
        const Product(
          id: 'redbull',
          name: '레드불 250ml',
          category: '에너지드링크',
          price: 2800,
          promotionType: 'fixed_price',
          promotionGroup: 'energy',
        ),
        // 일반 상품
        const Product(
          id: 'milk',
          name: '서울우유 1L',
          category: '유제품',
          price: 2500,
          promotionType: null,
          promotionGroup: null,
        ),
      ];

      // 모든 프로모션 설정
      pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));
      pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'coffee'));
      pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));
      pipeline.addPromotion(
        const FreeGiftPromotion(group: 'water', giftProductId: 'ramen1'),
      );
      pipeline.addPromotion(
        const FixedPricePromotion(group: 'energy', fixedPrice: 2000),
      );
    });

    group('실제 시나리오 테스트', () {
      test('학생 A: 콜라 2개, 사이다 1개 구매 → 1+1 프로모션으로 사이다 무료', () {
        final cartItems = [
          CartItem(product: products[0], quantity: 2), // 콜라 2개
          CartItem(product: products[1], quantity: 1), // 사이다 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);

        // 콜라: 2개 중 1개 무료
        expect(result[0].product.name, '코카콜라 500ml');
        expect(result[0].quantity, 2);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 1800); // 1개 가격

        // 사이다: 1개 중 0개 무료
        expect(result[1].product.name, '스프라이트 500ml');
        expect(result[1].quantity, 1);
        expect(result[1].freeQuantity, 0);
        expect(result[1].totalPrice, 1800); // 1개 가격

        // 총 결제 금액: 3600원
        final totalPrice = result.fold(0, (sum, item) => sum + item.totalPrice);
        expect(totalPrice, 3600);
      });

      test('학생 B: 초코바 3개 구매 → 2+1 프로모션으로 1개 무료', () {
        final cartItems = [
          CartItem(product: products[3], quantity: 3), // 초코바 3개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].product.name, '스누피 초코바');
        expect(result[0].quantity, 3);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 3000); // 2개 가격
      });

      test('학생 C: 생수 1개, 컵라면 1개 구매 → 생수 구매 시 컵라면 증정', () {
        final cartItems = [
          CartItem(product: products[5], quantity: 1), // 생수 1개
          CartItem(product: products[6], quantity: 1), // 컵라면 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);

        // 생수: 일반 상품
        expect(result[0].product.name, '삼다수 2L');
        expect(result[0].quantity, 1);
        expect(result[0].freeQuantity, 0);
        expect(result[0].totalPrice, 1200);

        // 컵라면: 증정 상품
        expect(result[1].product.name, '농심 신라면 컵');
        expect(result[1].quantity, 1);
        expect(result[1].freeQuantity, 1);
        expect(result[1].isGift, true);
        expect(result[1].totalPrice, 0);

        // 총 결제 금액: 1200원
        final totalPrice = result.fold(0, (sum, item) => sum + item.totalPrice);
        expect(totalPrice, 1200);
      });

      test('직장인 A: 에너지드링크 2개 구매 → 고정가격 2,000원 적용', () {
        final cartItems = [
          CartItem(product: products[7], quantity: 2), // 레드불 2개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].product.name, '레드불 250ml');
        expect(result[0].quantity, 2);
        expect(result[0].freeQuantity, 0);
        expect(result[0].product.price, 2000); // 고정 가격
        expect(result[0].totalPrice, 4000); // 2개 * 2000원
      });

      test('직장인 B: 커피 2개, 우유 1개 구매 → 커피 1+1 프로모션 적용', () {
        final cartItems = [
          CartItem(product: products[2], quantity: 2), // 커피 2개
          CartItem(product: products[8], quantity: 1), // 우유 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);

        // 커피: 2개 중 1개 무료
        expect(result[0].product.name, '맥스웰하우스 커피 275ml');
        expect(result[0].quantity, 2);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 1200); // 1개 가격

        // 우유: 일반 상품
        expect(result[1].product.name, '서울우유 1L');
        expect(result[1].quantity, 1);
        expect(result[1].freeQuantity, 0);
        expect(result[1].totalPrice, 2500);

        // 총 결제 금액: 3700원
        final totalPrice = result.fold(0, (sum, item) => sum + item.totalPrice);
        expect(totalPrice, 3700);
      });
    });

    group('복합 시나리오 테스트', () {
      test('대량 구매 시나리오: 음료수 10개, 과자 9개, 에너지드링크 5개', () {
        final cartItems = [
          CartItem(product: products[0], quantity: 10), // 콜라 10개
          CartItem(product: products[3], quantity: 9), // 초코바 9개
          CartItem(product: products[7], quantity: 5), // 레드불 5개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 3);

        // 콜라: 10개 중 5개 무료 (1+1)
        expect(result[0].product.name, '코카콜라 500ml');
        expect(result[0].quantity, 10);
        expect(result[0].freeQuantity, 5);
        expect(result[0].totalPrice, 9000); // 5개 가격

        // 초코바: 9개 중 3개 무료 (2+1)
        expect(result[1].product.name, '스누피 초코바');
        expect(result[1].quantity, 9);
        expect(result[1].freeQuantity, 3);
        expect(result[1].totalPrice, 9000); // 6개 가격

        // 레드불: 5개 고정 가격 적용
        expect(result[2].product.name, '레드불 250ml');
        expect(result[2].quantity, 5);
        expect(result[2].freeQuantity, 0);
        expect(result[2].totalPrice, 10000); // 5개 * 2000원

        // 총 결제 금액: 28000원
        final totalPrice = result.fold(0, (sum, item) => sum + item.totalPrice);
        expect(totalPrice, 28000);
      });

      test('교차 증정 복합 시나리오: 다양한 음료수 + 과자 + 생수 + 컵라면', () {
        final cartItems = [
          CartItem(product: products[0], quantity: 3), // 콜라 3개
          CartItem(product: products[1], quantity: 2), // 사이다 2개
          CartItem(product: products[2], quantity: 1), // 커피 1개
          CartItem(product: products[3], quantity: 4), // 초코바 4개
          CartItem(product: products[4], quantity: 2), // 칩 2개
          CartItem(product: products[5], quantity: 1), // 생수 1개
          CartItem(product: products[6], quantity: 1), // 컵라면 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 7);

        // 음료수 그룹 (콜라 + 사이다): 총 5개 중 2개 무료
        expect(result[0].product.name, '코카콜라 500ml');
        expect(result[0].freeQuantity, 2); // 3개 중 2개 무료

        expect(result[1].product.name, '스프라이트 500ml');
        expect(result[1].freeQuantity, 0); // 2개 중 0개 무료

        // 커피: 1개 중 0개 무료
        expect(result[2].product.name, '맥스웰하우스 커피 275ml');
        expect(result[2].freeQuantity, 0);

        // 과자 그룹 (초코바 + 칩): 총 6개 중 2개 무료
        expect(result[3].product.name, '스누피 초코바');
        expect(result[3].freeQuantity, 1); // 4개 중 1개 무료

        expect(result[4].product.name, '포카칩 오리지널');
        expect(result[4].freeQuantity, 1); // 2개 중 1개 무료

        // 생수: 일반 상품
        expect(result[5].product.name, '삼다수 2L');
        expect(result[5].freeQuantity, 0);

        // 컵라면: 증정 상품
        expect(result[6].product.name, '농심 신라면 컵');
        expect(result[6].freeQuantity, 1);
        expect(result[6].isGift, true);

        // 총 결제 금액 계산
        final totalPrice = result.fold(0, (sum, item) => sum + item.totalPrice);
        expect(totalPrice, greaterThan(0));
      });
    });

    group('엣지 케이스 시나리오', () {
      test('프로모션 조건 미충족 시나리오', () {
        final cartItems = [
          CartItem(product: products[0], quantity: 1), // 콜라 1개 (1+1 미충족)
          CartItem(product: products[3], quantity: 2), // 초코바 2개 (2+1 미충족)
          CartItem(product: products[8], quantity: 1), // 우유 1개 (프로모션 없음)
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 3);

        // 모든 상품이 프로모션 조건 미충족으로 일반 가격
        for (final item in result) {
          expect(item.freeQuantity, 0);
          expect(item.totalPrice, item.product.price * item.quantity);
        }
      });

      test('매우 큰 수량의 프로모션 테스트', () {
        final cartItems = [
          CartItem(product: products[0], quantity: 1000), // 콜라 1000개
          CartItem(product: products[3], quantity: 999), // 초코바 999개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);

        // 콜라: 1000개 중 500개 무료 (1+1)
        expect(result[0].quantity, 1000);
        expect(result[0].freeQuantity, 500);
        expect(result[0].totalPrice, 900000); // 500개 * 1800원

        // 초코바: 999개 중 333개 무료 (2+1)
        expect(result[1].quantity, 999);
        expect(result[1].freeQuantity, 333);
        expect(result[1].totalPrice, 999000); // 666개 * 1500원
      });

      test('0개 수량 처리', () {
        final cartItems = [
          CartItem(product: products[0], quantity: 0), // 콜라 0개
          CartItem(product: products[3], quantity: 0), // 초코바 0개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);

        for (final item in result) {
          expect(item.quantity, 0);
          expect(item.freeQuantity, 0);
          expect(item.totalPrice, 0);
        }
      });
    });

    group('프로모션 파이프라인 동적 관리 테스트', () {
      test('프로모션 동적 추가/제거', () {
        // 초기 상태: 프로모션 없음
        final emptyPipeline = PromotionPipeline();
        var cartItems = [
          CartItem(product: products[0], quantity: 2), // 콜라 2개
        ];

        var result = emptyPipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 0); // 프로모션 없음

        // 1+1 프로모션 추가
        emptyPipeline.addPromotion(
          const BuyOneGetOnePromotion(group: 'beverage'),
        );
        result = emptyPipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 1); // 프로모션 적용

        // 프로모션 제거
        emptyPipeline.removePromotion(
          const BuyOneGetOnePromotion(group: 'beverage'),
        );
        result = emptyPipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 0); // 프로모션 제거됨
      });

      test('프로모션 우선순위 테스트', () {
        // 동일한 그룹에 여러 프로모션 적용 시나리오
        final cartItems = [
          CartItem(product: products[0], quantity: 2), // 콜라 2개
        ];

        // 1+1 프로모션만 적용
        final pipeline1 = PromotionPipeline();
        pipeline1.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));
        var result = pipeline1.processCart(cartItems);
        expect(result[0].freeQuantity, 1);

        // 고정 가격 프로모션 추가
        pipeline1.addPromotion(
          const FixedPricePromotion(group: 'beverage', fixedPrice: 1000),
        );
        result = pipeline1.processCart(cartItems);
        expect(result[0].product.price, 1000); // 고정 가격 적용
        expect(result[0].freeQuantity, 0); // 1+1은 무시됨
      });
    });
  });
}
