import 'package:flutter_test/flutter_test.dart';
import 'package:convenience_store_pos_app/domain/model/product.dart';
import 'package:convenience_store_pos_app/domain/model/cart_item.dart';
import 'package:convenience_store_pos_app/domain/model/promotion.dart';
import 'package:convenience_store_pos_app/domain/promotion/promotion_pipeline.dart';

void main() {
  group('PromotionPipeline Tests', () {
    late PromotionPipeline pipeline;
    late List<Product> testProducts;

    setUp(() {
      pipeline = PromotionPipeline();
      testProducts = [
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
        const Product(
          id: 'ramen2',
          name: '오뚜기 진라면컵',
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
        const Product(
          id: 'monster',
          name: '몬스터에너지 355ml',
          category: '에너지드링크',
          price: 3200,
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
    });

    group('1+1 프로모션 테스트', () {
      test('1개 구매 시 1개 가격', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 1), // 콜라 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 1);
        expect(result[0].freeQuantity, 0);
        expect(result[0].totalPrice, 1800);
      });

      test('2개 구매 시 1개 가격', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 2);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 1800);
      });

      test('3개 구매 시 2개 가격', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 3), // 콜라 3개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 3);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 3600);
      });

      test('4개 구매 시 2개 가격', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 4), // 콜라 4개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 4);
        expect(result[0].freeQuantity, 2);
        expect(result[0].totalPrice, 3600);
      });

      test('99개 구매 시 50개 가격', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 99), // 콜라 99개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 99);
        expect(result[0].freeQuantity, 49);
        expect(result[0].totalPrice, 90000); // 50개 * 1800원
      });

      test('100개 구매 시 50개 가격', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 100), // 콜라 100개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 100);
        expect(result[0].freeQuantity, 50);
        expect(result[0].totalPrice, 90000); // 50개 * 1800원
      });

      test('교차 증정 테스트 - 콜라 1개 + 스프라이트 1개', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 1), // 콜라 1개
          CartItem(product: testProducts[1], quantity: 1), // 스프라이트 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);
        // 총 2개 중 1개 무료이므로 비율에 따라 분배
        expect(result[0].freeQuantity, 1); // 콜라 1개 무료 (50% 비율)
        expect(result[1].freeQuantity, 0); // 스프라이트 0개 무료
        expect(result[0].totalPrice, 0); // 콜라 무료
        expect(result[1].totalPrice, 1800); // 스프라이트 1개 가격
      });

      test('교차 증정 테스트 - 콜라 2개 + 스프라이트 1개', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
          CartItem(product: testProducts[1], quantity: 1), // 스프라이트 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);
        // 총 3개 중 1개 무료이므로 비율에 따라 분배
        expect(result[0].freeQuantity, 1); // 콜라 1개 무료
        expect(result[1].freeQuantity, 0); // 스프라이트 0개 무료
        expect(result[0].totalPrice, 1800); // 콜라 1개 가격
        expect(result[1].totalPrice, 1800); // 스프라이트 1개 가격
      });
    });

    group('2+1 프로모션 테스트', () {
      test('1개 구매 시 1개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 1), // 초코바 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 1);
        expect(result[0].freeQuantity, 0);
        expect(result[0].totalPrice, 1500);
      });

      test('2개 구매 시 2개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 2), // 초코바 2개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 2);
        expect(result[0].freeQuantity, 0);
        expect(result[0].totalPrice, 3000);
      });

      test('3개 구매 시 2개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 3), // 초코바 3개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 3);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 3000);
      });

      test('4개 구매 시 3개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 4), // 초코바 4개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 4);
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 4500);
      });

      test('6개 구매 시 4개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 6), // 초코바 6개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 6);
        expect(result[0].freeQuantity, 2);
        expect(result[0].totalPrice, 6000);
      });

      test('99개 구매 시 66개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 99), // 초코바 99개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 99);
        expect(result[0].freeQuantity, 33);
        expect(result[0].totalPrice, 99000); // 66개 * 1500원
      });

      test('100개 구매 시 67개 가격', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 100), // 초코바 100개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 100);
        expect(result[0].freeQuantity, 33);
        expect(result[0].totalPrice, 100500); // 67개 * 1500원
      });

      test('교차 증정 테스트 - 초코바 2개 + 칩 1개', () {
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[3], quantity: 2), // 초코바 2개
          CartItem(product: testProducts[4], quantity: 1), // 칩 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);
        // 총 3개 중 1개 무료이므로 비율에 따라 분배
        expect(result[0].freeQuantity, 1); // 초코바 1개 무료
        expect(result[1].freeQuantity, 0); // 칩 0개 무료
        expect(result[0].totalPrice, 1500); // 초코바 1개 가격
        expect(result[1].totalPrice, 1500); // 칩 1개 가격
      });
    });

    group('무료 증정 프로모션 테스트', () {
      test('생수 구매 시 컵라면 증정', () {
        pipeline.addPromotion(
          const FreeGiftPromotion(group: 'water', giftProductId: 'ramen1'),
        );

        final cartItems = [
          CartItem(product: testProducts[5], quantity: 1), // 생수 1개
          CartItem(product: testProducts[6], quantity: 1), // 컵라면 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);
        expect(result[0].isGift, false); // 생수는 일반 상품
        expect(result[1].isGift, true); // 컵라면은 증정 상품
        expect(result[1].freeQuantity, 1); // 컵라면 1개 무료
        expect(result[0].totalPrice, 1200); // 생수 1개 가격
        expect(result[1].totalPrice, 0); // 컵라면 무료
      });

      test('생수 2개 구매 시 컵라면 1개 증정', () {
        pipeline.addPromotion(
          const FreeGiftPromotion(group: 'water', giftProductId: 'ramen1'),
        );

        final cartItems = [
          CartItem(product: testProducts[5], quantity: 2), // 생수 2개
          CartItem(product: testProducts[6], quantity: 1), // 컵라면 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);
        expect(result[0].isGift, false); // 생수는 일반 상품
        expect(result[1].isGift, true); // 컵라면은 증정 상품
        expect(result[1].freeQuantity, 1); // 컵라면 1개 무료
        expect(result[0].totalPrice, 2400); // 생수 2개 가격
        expect(result[1].totalPrice, 0); // 컵라면 무료
      });
    });

    group('고정 가격 프로모션 테스트', () {
      test('에너지드링크 고정 가격 적용', () {
        pipeline.addPromotion(
          const FixedPricePromotion(group: 'energy', fixedPrice: 2000),
        );

        final cartItems = [
          CartItem(product: testProducts[8], quantity: 1), // 레드불 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].product.price, 2000); // 고정 가격으로 변경됨
        expect(result[0].totalPrice, 2000); // 고정 가격 적용
      });

      test('다른 에너지드링크 고정 가격 적용', () {
        pipeline.addPromotion(
          const FixedPricePromotion(group: 'energy', fixedPrice: 2200),
        );

        final cartItems = [
          CartItem(product: testProducts[9], quantity: 1), // 몬스터 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].product.price, 2200); // 고정 가격으로 변경됨
        expect(result[0].totalPrice, 2200); // 고정 가격 적용
      });
    });

    group('복합 프로모션 테스트', () {
      test('1+1과 2+1 동시 적용', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
          CartItem(product: testProducts[3], quantity: 3), // 초코바 3개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 2);
        // 콜라 2개 중 1개 무료
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 1800);
        // 초코바 3개 중 1개 무료
        expect(result[1].freeQuantity, 1);
        expect(result[1].totalPrice, 3000);
      });

      test('1+1과 무료 증정 동시 적용', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));
        pipeline.addPromotion(
          const FreeGiftPromotion(group: 'water', giftProductId: 'ramen1'),
        );

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
          CartItem(product: testProducts[5], quantity: 1), // 생수 1개
          CartItem(product: testProducts[6], quantity: 1), // 컵라면 1개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 3);
        // 콜라 2개 중 1개 무료
        expect(result[0].freeQuantity, 1);
        expect(result[0].totalPrice, 1800);
        // 생수 1개 가격
        expect(result[1].totalPrice, 1200);
        // 컵라면 무료 증정
        expect(result[2].isGift, true);
        expect(result[2].totalPrice, 0);
      });
    });

    group('프로모션 파이프라인 관리 테스트', () {
      test('프로모션 추가', () {
        expect(pipeline.processCart([]).length, 0);

        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].freeQuantity, 1);
      });

      test('프로모션 제거', () {
        final promotion = const BuyOneGetOnePromotion(group: 'beverage');
        pipeline.addPromotion(promotion);

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
        ];

        // 프로모션 적용 확인
        var result = pipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 1);

        // 프로모션 제거
        pipeline.removePromotion(promotion);

        // 프로모션 미적용 확인
        result = pipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 0);
      });

      test('프로모션 초기화', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));
        pipeline.addPromotion(const BuyTwoGetOnePromotion(group: 'snack'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 2), // 콜라 2개
        ];

        // 프로모션 적용 확인
        var result = pipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 1);

        // 프로모션 초기화
        pipeline.clearPromotions();

        // 프로모션 미적용 확인
        result = pipeline.processCart(cartItems);
        expect(result[0].freeQuantity, 0);
      });
    });

    group('엣지 케이스 테스트', () {
      test('빈 장바구니', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final result = pipeline.processCart([]);

        expect(result.length, 0);
      });

      test('프로모션 없는 상품', () {
        final cartItems = [
          CartItem(product: testProducts[10], quantity: 2), // 우유 2개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].freeQuantity, 0);
        expect(result[0].totalPrice, 5000); // 2개 * 2500원
      });

      test('0개 수량', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 0), // 콜라 0개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 0);
        expect(result[0].freeQuantity, 0);
        expect(result[0].totalPrice, 0);
      });

      test('매우 큰 수량', () {
        pipeline.addPromotion(const BuyOneGetOnePromotion(group: 'beverage'));

        final cartItems = [
          CartItem(product: testProducts[0], quantity: 1000000), // 콜라 100만개
        ];

        final result = pipeline.processCart(cartItems);

        expect(result.length, 1);
        expect(result[0].quantity, 1000000);
        expect(result[0].freeQuantity, 500000); // 50만개 무료
        expect(result[0].totalPrice, 900000000); // 50만개 * 1800원
      });
    });
  });
}
