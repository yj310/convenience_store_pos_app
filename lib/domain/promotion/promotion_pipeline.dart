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

    return processedItems;
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

      // 2개씩 묶어서 처리
      for (int i = 0; i < eligibleItems.length - 1; i += 2) {
        final item1 = eligibleItems[i];
        final item2 = eligibleItems[i + 1];
        
        // 더 저렴한 상품을 증정품으로 설정
        final giftItem = item1.product.price <= item2.product.price ? item1 : item2;
        final giftIndex = items.indexOf(giftItem);
        
        if (giftIndex != -1) {
          items[giftIndex] = giftItem.copyWith(
            isGift: true,
            appliedPromotion: promotion.type,
          );
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

      // 3개씩 묶어서 처리
      for (int i = 0; i < eligibleItems.length - 2; i += 3) {
        final item1 = eligibleItems[i];
        final item2 = eligibleItems[i + 1];
        final item3 = eligibleItems[i + 2];
        
        // 가장 저렴한 상품을 증정품으로 설정
        final giftItem = item1.product.price <= item2.product.price 
            ? (item1.product.price <= item3.product.price ? item1 : item3)
            : (item2.product.price <= item3.product.price ? item2 : item3);
        
        final giftIndex = items.indexOf(giftItem);
        
        if (giftIndex != -1) {
          items[giftIndex] = giftItem.copyWith(
            isGift: true,
            appliedPromotion: promotion.type,
          );
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
