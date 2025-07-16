import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final bool isGift;
  final String? appliedPromotion;
  final int freeQuantity;

  const CartItem({
    required this.product,
    required this.quantity,
    this.isGift = false,
    this.appliedPromotion,
    this.freeQuantity = 0,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isGift,
    String? appliedPromotion,
    int? freeQuantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isGift: isGift ?? this.isGift,
      appliedPromotion: appliedPromotion ?? this.appliedPromotion,
      freeQuantity: freeQuantity ?? this.freeQuantity,
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
  ];
}
