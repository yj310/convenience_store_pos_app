import '../model/product.dart';
import '../model/cart_item.dart';
import '../model/promotion.dart';

class PromotionPipeline {
  final List<Promotion> _promotions;

  PromotionPipeline({List<Promotion>? promotions})
    : _promotions = promotions ?? [];

  void addPromotion(Promotion promotion) {
    _promotions.add(promotion);
  }

  void removePromotion(Promotion promotion) {
    _promotions.remove(promotion);
  }

  void clearPromotions() {
    _promotions.clear();
  }

  List<CartItem> processCart(List<CartItem> cartItems) {
    if (_promotions.isEmpty) return cartItems;

    List<CartItem> processedItems = List.from(cartItems);
    print('=== 프로모션 파이프라인 시작 ===');
    print(
      '입력 아이템: ${processedItems.map((item) => '${item.product.name} ${item.quantity}개').join(', ')}',
    );

    // 1+1 프로모션 처리
    _processBuyOneGetOne(processedItems);

    // 2+1 프로모션 처리
    _processBuyTwoGetOne(processedItems);

    // 무료 증정 프로모션 처리
    _processFreeGift(processedItems);

    // 고정 가격 프로모션 처리
    _processFixedPrice(processedItems);

    // 같은 상품끼리 합치기
    final result = _mergeSameProducts(processedItems);
    print(
      '결과 아이템: ${result.map((item) => '${item.product.name} ${item.quantity}개 (무료:${item.freeQuantity}개)').join(', ')}',
    );
    print('=== 프로모션 파이프라인 종료 ===');
    return result;
  }

  List<CartItem> _mergeSameProducts(List<CartItem> items) {
    final Map<String, CartItem> mergedItems = {};

    for (final item in items) {
      final key =
          '${item.product.id}_${item.appliedPromotion}_${item.freeQuantity}_${item.groupId}';

      if (mergedItems.containsKey(key)) {
        // 같은 상품이면 수량 합치기
        final existingItem = mergedItems[key]!;
        mergedItems[key] = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity,
        );
      } else {
        // 새로운 상품이면 추가
        mergedItems[key] = item;
      }
    }

    return mergedItems.values.toList();
  }

  void _processBuyOneGetOne(List<CartItem> items) {
    final buyOneGetOnePromotions = _promotions
        .whereType<BuyOneGetOnePromotion>()
        .toList();

    print(
      '1+1 프로모션 처리 시작: ${buyOneGetOnePromotions.map((p) => p.group).join(', ')}',
    );

    for (final promotion in buyOneGetOnePromotions) {
      final eligibleItems = items
          .where((item) => item.product.promotionGroup == promotion.group)
          .toList();

      print(
        '${promotion.group} 그룹 아이템: ${eligibleItems.map((item) => '${item.product.name} ${item.quantity}개').join(', ')}',
      );

      int totalQuantity = eligibleItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );
      // 1+1 프로모션: 2개당 1개 무료
      // 1개 구매: 1개 가격, 2개 구매: 1개 가격, 3개 구매: 2개 가격, 4개 구매: 2개 가격
      int payQuantity = (totalQuantity + 1) ~/ 2;
      int freeQuantity = totalQuantity - payQuantity;

      print('총 수량: $totalQuantity, 결제 수량: $payQuantity, 무료 수량: $freeQuantity');

      if (freeQuantity > 0) {
        // 그룹 내에서 무료 수량을 균등하게 분배
        int remainingFree = freeQuantity;
        int totalEligibleQuantity = totalQuantity;

        for (final item in eligibleItems) {
          final itemIndex = items.indexOf(item);
          if (itemIndex != -1) {
            final currentItem = items[itemIndex];
            // 비율에 따라 무료 수량 계산
            final freeRatio = currentItem.quantity / totalEligibleQuantity;
            final freeCount = (freeQuantity * freeRatio).round();
            final actualFreeCount = remainingFree > freeCount
                ? freeCount
                : remainingFree;

            items[itemIndex] = currentItem.copyWith(
              freeQuantity: actualFreeCount,
              appliedPromotion: promotion.type,
              groupId: promotion.group,
            );
            print(
              '${currentItem.product.name}에 무료 ${actualFreeCount}개 적용 (비율: ${(freeRatio * 100).toStringAsFixed(1)}%)',
            );
            remainingFree -= actualFreeCount;
          }
        }
      } else {
        // 무료수량 없음, appliedPromotion만 표시
        for (final item in eligibleItems) {
          final itemIndex = items.indexOf(item);
          if (itemIndex != -1) {
            items[itemIndex] = items[itemIndex].copyWith(
              freeQuantity: 0,
              appliedPromotion: promotion.type,
              groupId: promotion.group,
            );
          }
        }
      }
    }
  }

  void _processBuyTwoGetOne(List<CartItem> items) {
    final buyTwoGetOnePromotions = _promotions
        .whereType<BuyTwoGetOnePromotion>()
        .toList();

    print(
      '2+1 프로모션 처리 시작: ${buyTwoGetOnePromotions.map((p) => p.group).join(', ')}',
    );

    for (final promotion in buyTwoGetOnePromotions) {
      final eligibleItems = items
          .where((item) => item.product.promotionGroup == promotion.group)
          .toList();

      print(
        '${promotion.group} 그룹 아이템: ${eligibleItems.map((item) => '${item.product.name} ${item.quantity}개').join(', ')}',
      );

      // 총 수량 계산
      int totalQuantity = eligibleItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

      // 2+1 프로모션: 3개당 1개 무료
      // 1개 구매: 1개 가격, 2개 구매: 2개 가격, 3개 구매: 2개 가격, 4개 구매: 3개 가격
      int payQuantity = totalQuantity - (totalQuantity ~/ 3);
      int freeQuantity = totalQuantity - payQuantity;

      print('총 수량: $totalQuantity, 결제 수량: $payQuantity, 무료 수량: $freeQuantity');

      // 그룹 내에서 무료 수량을 균등하게 분배
      int remainingFree = freeQuantity;
      int totalEligibleQuantity = totalQuantity;

      for (final item in eligibleItems) {
        final itemIndex = items.indexOf(item);
        if (itemIndex != -1) {
          final currentItem = items[itemIndex];
          // 비율에 따라 무료 수량 계산
          final freeRatio = currentItem.quantity / totalEligibleQuantity;
          final freeCount = (freeQuantity * freeRatio).round();
          final actualFreeCount = remainingFree > freeCount
              ? freeCount
              : remainingFree;

          items[itemIndex] = currentItem.copyWith(
            freeQuantity: actualFreeCount,
            appliedPromotion: promotion.type,
            groupId: promotion.group,
          );
          print(
            '${currentItem.product.name}에 무료 ${actualFreeCount}개 적용 (비율: ${(freeRatio * 100).toStringAsFixed(1)}%)',
          );
          remainingFree -= actualFreeCount;
        }
      }
    }
  }

  void _processFreeGift(List<CartItem> items) {
    final freeGiftPromotions = _promotions
        .whereType<FreeGiftPromotion>()
        .toList();

    for (final promotion in freeGiftPromotions) {
      final triggerItems = items
          .where(
            (item) =>
                item.product.promotionGroup == promotion.group &&
                !item.isGift &&
                item.appliedPromotion == null,
          )
          .toList();

      if (triggerItems.isNotEmpty) {
        // 증정 상품이 이미 있는지 확인
        final existingGift = items
            .where((item) => item.product.id == promotion.giftProductId)
            .toList();

        if (existingGift.isEmpty) {
          // 증정 상품을 찾아서 추가
          final giftProduct = items
              .where((item) => item.product.id == promotion.giftProductId)
              .firstOrNull;

          if (giftProduct != null) {
            // 기존 증정 상품을 무료로 설정
            final giftIndex = items.indexOf(giftProduct);
            if (giftIndex != -1) {
              items[giftIndex] = giftProduct.copyWith(
                isGift: true,
                appliedPromotion: promotion.type,
                freeQuantity: giftProduct.quantity, // 전체 수량을 무료로
              );
            }
          } else {
            // 증정 상품이 장바구니에 없으면 새로 추가
            final giftProductData = _getGiftProductData(
              promotion.giftProductId,
            );
            if (giftProductData != null) {
              final newGiftItem = CartItem(
                product: giftProductData,
                quantity: 1,
                isGift: true,
                appliedPromotion: promotion.type,
                freeQuantity: 1, // 1개 무료
              );
              items.add(newGiftItem);
              print('증정 상품 추가: ${giftProductData.name}');
            }
          }
        } else {
          // 기존 증정 상품을 무료로 설정
          for (final giftItem in existingGift) {
            final giftIndex = items.indexOf(giftItem);
            if (giftIndex != -1) {
              items[giftIndex] = giftItem.copyWith(
                isGift: true,
                appliedPromotion: promotion.type,
                freeQuantity: giftItem.quantity, // 전체 수량을 무료로
              );
            }
          }
        }
      }
    }
  }

  // 증정 상품 데이터를 가져오는 헬퍼 메서드
  Product? _getGiftProductData(String productId) {
    // Mock 데이터에서 증정 상품 정보 가져오기
    final mockProducts = {
      'nongshim_cup': const Product(
        id: 'nongshim_cup',
        name: '농심 신라면 컵',
        category: '컵라면',
        price: 1100,
        promotionType: null,
        promotionGroup: 'instant',
        note: '증정 대상',
      ),
      'ottogi_cup': const Product(
        id: 'ottogi_cup',
        name: '오뚜기 진라면 컵',
        category: '컵라면',
        price: 1100,
        promotionType: null,
        promotionGroup: 'instant',
        note: '증정 대상',
      ),
    };

    return mockProducts[productId];
  }

  void _processFixedPrice(List<CartItem> items) {
    final fixedPricePromotions = _promotions
        .whereType<FixedPricePromotion>()
        .toList();

    for (final promotion in fixedPricePromotions) {
      final eligibleItems = items
          .where(
            (item) =>
                item.product.promotionGroup == promotion.group &&
                !item.isGift &&
                item.appliedPromotion == null,
          )
          .toList();

      for (final item in eligibleItems) {
        final itemIndex = items.indexOf(item);
        if (itemIndex != -1) {
          // 고정 가격으로 상품 가격을 임시로 변경
          final fixedPriceProduct = Product(
            id: item.product.id,
            name: item.product.name,
            category: item.product.category,
            price: promotion.fixedPrice,
            promotionType: item.product.promotionType,
            promotionGroup: item.product.promotionGroup,
            note: item.product.note,
          );

          items[itemIndex] = item.copyWith(
            product: fixedPriceProduct,
            appliedPromotion: promotion.type,
          );
        }
      }
    }
  }
}
