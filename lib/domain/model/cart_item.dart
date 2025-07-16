import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final bool isGift;
  final String? appliedPromotion;

  const CartItem({
    required this.product,
    required this.quantity,
    this.isGift = false,
    this.appliedPromotion,
  });

  CartItem copyWith({
    Product? product,
    int? quantity,
    bool? isGift,
    String? appliedPromotion,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isGift: isGift ?? this.isGift,
      appliedPromotion: appliedPromotion ?? this.appliedPromotion,
    );
  }

  int get totalPrice => product.price * quantity;

  @override
  List<Object?> get props => [product, quantity, isGift, appliedPromotion];
}
