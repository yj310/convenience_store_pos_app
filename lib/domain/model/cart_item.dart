import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final bool isGift;
  final String? appliedPromotion;
  final int freeQuantity;
  final String? groupId; // 같은 그룹의 상품들을 묶기 위한 ID

  const CartItem({
    required this.product,
    required this.quantity,
    this.isGift = false,
    this.appliedPromotion,
    this.freeQuantity = 0,
    this.groupId,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isGift,
    String? appliedPromotion,
    int? freeQuantity,
    String? groupId,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isGift: isGift ?? this.isGift,
      appliedPromotion: appliedPromotion ?? this.appliedPromotion,
      freeQuantity: freeQuantity ?? this.freeQuantity,
      groupId: groupId ?? this.groupId,
    );
  }

  int get totalPrice => product.price * (quantity - freeQuantity);

  @override
  List<Object?> get props => [
    product,
    quantity,
    isGift,
    appliedPromotion,
    freeQuantity,
    groupId,
  ];
}
