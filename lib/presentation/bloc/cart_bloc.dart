import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/model/product.dart';
import '../../domain/model/cart_item.dart';
import '../../domain/promotion/promotion_pipeline.dart';
import '../../domain/repository/product_repository.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddProductToCart extends CartEvent {
  final Product product;

  const AddProductToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveProductFromCart extends CartEvent {
  final String productId;

  const RemoveProductFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateProductQuantity extends CartEvent {
  final String productId;
  final int quantity;

  const UpdateProductQuantity(this.productId, this.quantity);

  @override
  List<Object?> get props => [productId, quantity];
}

class ClearCart extends CartEvent {}

class LoadProducts extends CartEvent {}

class ScanBarcode extends CartEvent {
  final String barcode;

  const ScanBarcode(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> cartItems;
  final List<Product> availableProducts;
  final int totalPrice;
  final String? error;

  const CartLoaded({
    required this.cartItems,
    required this.availableProducts,
    required this.totalPrice,
    this.error,
  });

  @override
  List<Object?> get props => [cartItems, availableProducts, totalPrice, error];

  CartLoaded copyWith({
    List<CartItem>? cartItems,
    List<Product>? availableProducts,
    int? totalPrice,
    String? error,
  }) {
    return CartLoaded(
      cartItems: cartItems ?? this.cartItems,
      availableProducts: availableProducts ?? this.availableProducts,
      totalPrice: totalPrice ?? this.totalPrice,
      error: error,
    );
  }
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final ProductRepository _productRepository;
  final PromotionPipeline _promotionPipeline;

  CartBloc({
    required ProductRepository productRepository,
    PromotionPipeline? promotionPipeline,
  }) : _productRepository = productRepository,
       _promotionPipeline = promotionPipeline ?? PromotionPipeline(),
       super(CartInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProductToCart>(_onAddProductToCart);
    on<RemoveProductFromCart>(_onRemoveProductFromCart);
    on<UpdateProductQuantity>(_onUpdateProductQuantity);
    on<ClearCart>(_onClearCart);
    on<ScanBarcode>(_onScanBarcode);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<CartState> emit,
  ) async {
    emit(CartLoading());
    try {
      final products = await _productRepository.getProducts();
      emit(
        CartLoaded(
          cartItems: const [],
          availableProducts: products,
          totalPrice: 0,
        ),
      );
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  void _onAddProductToCart(AddProductToCart event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;

      // 같은 상품 중 유료 상품을 찾기 (증정 상품이 아닌 것)
      final existingItemIndex = currentState.cartItems.indexWhere(
        (item) => item.product.id == event.product.id && !item.isGift,
      );

      List<CartItem> newCartItems = List.from(currentState.cartItems);

      if (existingItemIndex != -1) {
        // 기존 유료 상품이 있으면 수량 증가
        final existingItem = newCartItems[existingItemIndex];
        newCartItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + 1,
        );
      } else {
        // 새 상품 추가 (유료로 추가)
        newCartItems.add(CartItem(product: event.product, quantity: 1));
      }

      // 프로모션 파이프라인 적용
      final processedItems = _promotionPipeline.processCart(newCartItems);
      final totalPrice = processedItems.fold<int>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      emit(
        currentState.copyWith(
          cartItems: processedItems,
          totalPrice: totalPrice,
        ),
      );
    }
  }

  void _onRemoveProductFromCart(
    RemoveProductFromCart event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final newCartItems = currentState.cartItems
          .where((item) => item.product.id != event.productId)
          .toList();

      // 프로모션 파이프라인 적용
      final processedItems = _promotionPipeline.processCart(newCartItems);
      final totalPrice = processedItems.fold<int>(
        0,
        (sum, item) => sum + item.totalPrice,
      );

      emit(
        currentState.copyWith(
          cartItems: processedItems,
          totalPrice: totalPrice,
        ),
      );
    }
  }

  void _onUpdateProductQuantity(
    UpdateProductQuantity event,
    Emitter<CartState> emit,
  ) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      final itemIndex = currentState.cartItems.indexWhere(
        (item) => item.product.id == event.productId,
      );

      if (itemIndex != -1) {
        List<CartItem> newCartItems = List.from(currentState.cartItems);

        if (event.quantity <= 0) {
          newCartItems.removeAt(itemIndex);
        } else {
          final item = newCartItems[itemIndex];
          newCartItems[itemIndex] = item.copyWith(quantity: event.quantity);
        }

        // 프로모션 파이프라인 적용
        final processedItems = _promotionPipeline.processCart(newCartItems);
        final totalPrice = processedItems.fold<int>(
          0,
          (sum, item) => sum + item.totalPrice,
        );

        emit(
          currentState.copyWith(
            cartItems: processedItems,
            totalPrice: totalPrice,
          ),
        );
      }
    }
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    if (state is CartLoaded) {
      final currentState = state as CartLoaded;
      emit(currentState.copyWith(cartItems: const [], totalPrice: 0));
    }
  }

  Future<void> _onScanBarcode(
    ScanBarcode event,
    Emitter<CartState> emit,
  ) async {
    try {
      final product = await _productRepository.getProductByBarcode(
        event.barcode,
      );
      if (product != null) {
        add(AddProductToCart(product));
      } else {
        if (state is CartLoaded) {
          final currentState = state as CartLoaded;
          emit(currentState.copyWith(error: '상품을 찾을 수 없습니다: ${event.barcode}'));
        }
      }
    } catch (e) {
      if (state is CartLoaded) {
        final currentState = state as CartLoaded;
        emit(currentState.copyWith(error: '바코드 스캔 오류: ${e.toString()}'));
      }
    }
  }
}
