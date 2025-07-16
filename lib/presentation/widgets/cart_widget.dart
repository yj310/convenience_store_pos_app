import 'package:flutter/material.dart';
import '../../domain/model/cart_item.dart';

class CartWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final int totalPrice;
  final Function(String) onRemoveItem;
  final Function(String, int) onUpdateQuantity;
  final VoidCallback onClearCart;

  const CartWidget({
    super.key,
    required this.cartItems,
    required this.totalPrice,
    required this.onRemoveItem,
    required this.onUpdateQuantity,
    required this.onClearCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '장바구니',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: onClearCart, child: const Text('비우기')),
              ],
            ),
          ),
          // 장바구니 아이템 목록
          Expanded(
            child: cartItems.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          '장바구니가 비어있습니다',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _buildGroupedCartItems(),
          ),
          // 총액 및 결제 버튼
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '총액:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: cartItems.isEmpty
                        ? null
                        : () {
                            // 결제 로직 구현
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('결제가 완료되었습니다!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            onClearCart();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      '결제하기',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedCartItems() {
    if (cartItems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '장바구니가 비어있습니다',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final groupedItems = <String, List<CartItem>>{};
    for (final item in cartItems) {
      final groupKey = item.product.name;
      groupedItems.update(
        groupKey,
        (list) => list..add(item),
        ifAbsent: () => [item],
      );
    }

    return ListView.builder(
      itemCount: groupedItems.length,
      itemBuilder: (context, index) {
        final groupKey = groupedItems.keys.elementAt(index);
        final groupItems = groupedItems[groupKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Text(
                groupKey,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...groupItems.map((item) {
              final hasPromotion = item.appliedPromotion != null;
              final hasFree = item.freeQuantity > 0;
              final unitPrice = item.product.price;
              final totalWithoutPromo = unitPrice * item.quantity;
              final totalWithPromo = item.totalPrice;
              return CartItemWidget(
                item: item,
                onRemove: () => onRemoveItem(item.product.id),
                onUpdateQuantity: (quantity) =>
                    onUpdateQuantity(item.product.id, quantity),
              );
            }).toList(),
          ],
        );
      },
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final Function(int) onUpdateQuantity;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final hasPromotion = item.appliedPromotion != null;
    final hasFree = item.freeQuantity > 0;
    final unitPrice = item.product.price;
    final totalWithoutPromo = unitPrice * item.quantity;
    final totalWithPromo = item.totalPrice;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasFree ? Colors.green[50] : Colors.white,
        border: Border.all(
          color: hasFree ? Colors.green : Colors.grey[300]!,
          width: hasFree ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (hasFree)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '증정',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (hasPromotion)
                      Text(
                        '프로모션: ${item.appliedPromotion}',
                        style: TextStyle(color: Colors.blue[600], fontSize: 12),
                      ),
                    if (hasFree)
                      Text(
                        '${item.quantity}개 중 ${item.freeQuantity}개 무료',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
                iconSize: 20,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${unitPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => onUpdateQuantity(item.quantity - 1),
                    icon: const Icon(Icons.remove, size: 16),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onUpdateQuantity(item.quantity + 1),
                    icon: const Icon(Icons.add, size: 16),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 가격 정보 3종 표시
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '프로모션 미적용: ${totalWithoutPromo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '프로모션 적용: ${totalWithPromo.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '1개당 ${unitPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
