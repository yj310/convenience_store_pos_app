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

    // 1+1 프로모션 처리
    _processBuyOneGetOne(processedItems);

    // 2+1 프로모션 처리
    _processBuyTwoGetOne(processedItems);

    // 무료 증정 프로모션 처리
    _processFreeGift(processedItems);

    // 고정 가격 프로모션 처리
    _processFixedPrice(processedItems);

    // 같은 상품끼리 합치기
    return _mergeSameProducts(processedItems);
  }

  List<CartItem> _mergeSameProducts(List<CartItem> items) {
    final Map<String, CartItem> mergedItems = {};

    for (final item in items) {
      final key = '${item.product.id}_${item.isGift}_${item.appliedPromotion}';

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

    for (final promotion in buyOneGetOnePromotions) {
      final eligibleItems = items
          .where(
            (item) =>
                item.product.promotionGroup == promotion.group &&
                !item.isGift &&
                item.appliedPromotion == null,
          )
          .toList();

      // 총 수량 계산
      int totalQuantity = eligibleItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

      // 1+1 프로모션: 2개당 1개 무료
      int freeQuantity = totalQuantity ~/ 2;

      if (freeQuantity > 0) {
        // 가격순으로 정렬 (저렴한 것부터 무료로)
        eligibleItems.sort(
          (a, b) => a.product.price.compareTo(b.product.price),
        );

        int remainingFree = freeQuantity;

        for (final item in eligibleItems) {
          if (remainingFree <= 0) break;

          final itemIndex = items.indexOf(item);
          if (itemIndex != -1) {
            final currentItem = items[itemIndex];
            final freeCount = remainingFree > currentItem.quantity
                ? currentItem.quantity
                : remainingFree;

            // 무료 수량 설정
            items[itemIndex] = currentItem.copyWith(
              freeQuantity: freeCount,
              appliedPromotion: promotion.type,
            );

            remainingFree -= freeCount;
          }
        }
      }
    }
  }

  void _processBuyTwoGetOne(List<CartItem> items) {
    final buyTwoGetOnePromotions = _promotions
        .whereType<BuyTwoGetOnePromotion>()
        .toList();

    for (final promotion in buyTwoGetOnePromotions) {
      final eligibleItems = items
          .where(
            (item) =>
                item.product.promotionGroup == promotion.group &&
                !item.isGift &&
                item.appliedPromotion == null,
          )
          .toList();

      // 총 수량 계산
      int totalQuantity = eligibleItems.fold(
        0,
        (sum, item) => sum + item.quantity,
      );

      // 2+1 프로모션: 3개당 1개 무료
      int freeQuantity = totalQuantity ~/ 3;

      if (freeQuantity > 0) {
        // 가격순으로 정렬 (저렴한 것부터 무료로)
        eligibleItems.sort(
          (a, b) => a.product.price.compareTo(b.product.price),
        );

        int remainingFree = freeQuantity;

        for (final item in eligibleItems) {
          if (remainingFree <= 0) break;

          final itemIndex = items.indexOf(item);
          if (itemIndex != -1) {
            final currentItem = items[itemIndex];
            final freeCount = remainingFree > currentItem.quantity
                ? currentItem.quantity
                : remainingFree;

            // 무료 수량 설정
            items[itemIndex] = currentItem.copyWith(
              freeQuantity: freeCount,
              appliedPromotion: promotion.type,
            );

            remainingFree -= freeCount;
          }
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
            .where(
              (item) =>
                  item.product.id == promotion.giftProductId && item.isGift,
            )
            .toList();

        if (existingGift.isEmpty) {
          // 증정 상품을 찾아서 추가
          final giftProduct = items
              .where((item) => item.product.id == promotion.giftProductId)
              .firstOrNull;

          if (giftProduct != null) {
            final giftIndex = items.indexOf(giftProduct);
            if (giftIndex != -1) {
              items[giftIndex] = giftProduct.copyWith(
                isGift: true,
                appliedPromotion: promotion.type,
              );
            }
          }
        }
      }
    }
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
