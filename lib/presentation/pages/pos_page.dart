import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/cart_widget.dart';
import '../widgets/product_list_widget.dart';
import '../widgets/barcode_scanner_widget.dart';
import '../widgets/barcode_global_listener.dart';

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BarcodeGlobalListener(
      onBarcodeScanned: (barcode) {
        context.read<CartBloc>().add(ScanBarcode(barcode));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('편의점 POS 시스템'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {
            if (state is CartInitial) {
              // 초기 상태에서 상품 목록 로드
              context.read<CartBloc>().add(LoadProducts());
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is CartError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      '오류가 발생했습니다',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(LoadProducts());
                      },
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              );
            }

            if (state is CartLoaded) {
              // 에러 메시지가 있으면 스낵바 표시
              if (state.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error!),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                      action: SnackBarAction(
                        label: '확인',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                  // 에러 메시지를 표시한 후 에러 상태를 클리어
                  context.read<CartBloc>().add(ClearError());
                });
              }

              return Row(
                children: [
                  // 왼쪽: 상품 목록 및 바코드 스캐너
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        // 바코드 스캐너
                        Container(
                          height: 160,
                          padding: const EdgeInsets.all(8),
                          child: BarcodeScannerWidget(
                            onBarcodeScanned: (barcode) {
                              context.read<CartBloc>().add(
                                ScanBarcode(barcode),
                              );
                            },
                          ),
                        ),
                        // 상품 목록
                        Expanded(
                          child: ProductListWidget(
                            products: state.availableProducts,
                            onProductSelected: (product) {
                              context.read<CartBloc>().add(
                                AddProductToCart(product),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 오른쪽: 장바구니
                  Expanded(
                    flex: 1,
                    child: CartWidget(
                      cartItems: state.cartItems,
                      totalPrice: state.totalPrice,
                      onRemoveItem: (productId) {
                        context.read<CartBloc>().add(
                          RemoveProductFromCart(productId),
                        );
                      },
                      onUpdateQuantity: (productId, quantity) {
                        context.read<CartBloc>().add(
                          UpdateProductQuantity(productId, quantity),
                        );
                      },
                      onClearCart: () {
                        context.read<CartBloc>().add(ClearCart());
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: Text('알 수 없는 상태입니다'));
          },
        ),
      ),
    );
  }
}
