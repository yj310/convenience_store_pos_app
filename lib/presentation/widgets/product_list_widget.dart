import 'package:flutter/material.dart';
import '../../domain/model/product.dart';

class ProductListWidget extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onProductSelected;

  const ProductListWidget({
    super.key,
    required this.products,
    required this.onProductSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 검색 바
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: '상품명으로 검색...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // 검색 기능 구현 (필요시)
            },
          ),
        ),
        // 상품 목록
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(
                product: product,
                onTap: () => onProductSelected(product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상품 이미지 (플레이스홀더)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    _getProductIcon(product.category),
                    size: 32,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // 상품명
              Text(
                product.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // 가격
              Text(
                '${product.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              // 프로모션 정보
              if (product.promotionType != null)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getPromotionDisplayText(product.promotionType!),
                    style: TextStyle(
                      color: Colors.orange[800],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category) {
      case '음료수':
        return Icons.local_drink;
      case '커피':
        return Icons.coffee;
      case '과자/스낵':
        return Icons.cake;
      case '생수':
        return Icons.water_drop;
      case '컵라면':
        return Icons.ramen_dining;
      case '에너지드링크':
        return Icons.bolt;
      case '유제품':
        return Icons.local_dining;
      case '빵류':
        return Icons.bakery_dining;
      case '도시락':
        return Icons.lunch_dining;
      case '아이스크림':
        return Icons.icecream;
      default:
        return Icons.shopping_bag;
    }
  }

  String _getPromotionDisplayText(String promotionType) {
    switch (promotionType) {
      case '1+1':
        return '1+1';
      case '2+1':
        return '2+1';
      case 'free_gift':
        return '무료 증정';
      case 'fixed_price':
        return '고정 가격';
      default:
        return promotionType;
    }
  }
}
