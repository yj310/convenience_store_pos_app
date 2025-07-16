import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/product_dto.dart';
import '../../domain/model/product.dart';

abstract class ProductDataSource {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<Product?> getProductByBarcode(String barcode);
}

class MockProductDataSource implements ProductDataSource {
  @override
  Future<List<Product>> getProducts() async {
    // Mock 데이터 반환
    await Future.delayed(const Duration(milliseconds: 500)); // 네트워크 지연 시뮬레이션

    return [
      const Product(
        id: 'cola_500ml',
        name: '코카콜라 500ml',
        category: '음료수',
        price: 1800,
        promotionType: '1+1',
        promotionGroup: 'beverage',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'sprite_500ml',
        name: '스프라이트 500ml',
        category: '음료수',
        price: 1800,
        promotionType: '1+1',
        promotionGroup: 'beverage',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'pepsi_500ml',
        name: '펩시콜라 500ml',
        category: '음료수',
        price: 1800,
        promotionType: '1+1',
        promotionGroup: 'beverage',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'maxwell_coffee_275ml',
        name: '맥스웰하우스 커피 275ml',
        category: '커피',
        price: 1200,
        promotionType: '1+1',
        promotionGroup: 'coffee',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'georgia_coffee_275ml',
        name: '조지아 커피 275ml',
        category: '커피',
        price: 1200,
        promotionType: '1+1',
        promotionGroup: 'coffee',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'snoopy_choco',
        name: '스누피 초코바',
        category: '과자/스낵',
        price: 1500,
        promotionType: '2+1',
        promotionGroup: 'snack',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'pokachip_original',
        name: '포카칩 오리지널',
        category: '과자/스낵',
        price: 1500,
        promotionType: '2+1',
        promotionGroup: 'snack',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'original_cookie',
        name: '오리지널 쿠키',
        category: '과자/스낵',
        price: 1500,
        promotionType: '2+1',
        promotionGroup: 'snack',
        note: '교차증정 가능',
      ),
      const Product(
        id: 'samdasoo_2l',
        name: '삼다수 2L',
        category: '생수',
        price: 1200,
        promotionType: 'free_gift',
        promotionGroup: 'water',
        note: '컵라면 증정',
      ),
      const Product(
        id: 'nongshim_cup',
        name: '농심 신라면 컵',
        category: '컵라면',
        price: 1100,
        promotionType: null,
        promotionGroup: 'instant',
        note: '증정 대상',
      ),
      const Product(
        id: 'ottogi_cup',
        name: '오뚜기 진라면 컵',
        category: '컵라면',
        price: 1100,
        promotionType: null,
        promotionGroup: 'instant',
        note: '증정 대상',
      ),
      const Product(
        id: 'redbull_250ml',
        name: '레드불 250ml',
        category: '에너지드링크',
        price: 2800,
        promotionType: 'fixed_price',
        promotionGroup: 'energy',
        note: '2,000원 특가',
      ),
      const Product(
        id: 'monster_355ml',
        name: '몬스터에너지 355ml',
        category: '에너지드링크',
        price: 3200,
        promotionType: 'fixed_price',
        promotionGroup: 'energy',
        note: '2,200원 특가',
      ),
      const Product(
        id: 'seoul_milk_1l',
        name: '서울우유 1L',
        category: '유제품',
        price: 2500,
        promotionType: null,
        promotionGroup: 'dairy',
        note: '일반 상품',
      ),
      const Product(
        id: 'yoplait_strawberry_150ml',
        name: '요플레 딸기 150ml',
        category: '유제품',
        price: 1200,
        promotionType: null,
        promotionGroup: 'dairy',
        note: '일반 상품',
      ),
      const Product(
        id: 'banana_milk_200ml',
        name: '바나나우유 200ml',
        category: '유제품',
        price: 1400,
        promotionType: null,
        promotionGroup: 'dairy',
        note: '일반 상품',
      ),
      const Product(
        id: 'bread_4pack',
        name: '빵빠레 4개입',
        category: '빵류',
        price: 2800,
        promotionType: null,
        promotionGroup: 'bread',
        note: '일반 상품',
      ),
      const Product(
        id: 'triangle_kimbap_tuna',
        name: '삼각김밥 참치마요',
        category: '도시락',
        price: 3500,
        promotionType: null,
        promotionGroup: 'meal',
        note: '일반 상품',
      ),
      const Product(
        id: 'dosirak_bulgogi',
        name: '도시락 제육볶음',
        category: '도시락',
        price: 4500,
        promotionType: null,
        promotionGroup: 'meal',
        note: '일반 상품',
      ),
      const Product(
        id: 'icecream_vanilla',
        name: '아이스크림 바 닐라',
        category: '아이스크림',
        price: 1500,
        promotionType: null,
        promotionGroup: 'icecream',
        note: '일반 상품',
      ),
    ];
  }

  @override
  Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Product?> getProductByBarcode(String barcode) async {
    // 바코드와 상품 ID 매핑 (실제로는 더 복잡한 로직이 필요)
    final barcodeToId = {
      '8801234567890': 'cola_500ml',
      '8801234567891': 'sprite_500ml',
      '8801234567892': 'pepsi_500ml',
      '8801234567893': 'maxwell_coffee_275ml',
      '8801234567894': 'georgia_coffee_275ml',
      '8801234567895': 'snoopy_choco',
      '8801234567896': 'pokachip_original',
      '8801234567897': 'original_cookie',
      '8801234567898': 'samdasoo_2l',
      '8801234567899': 'nongshim_cup',
      '8801234567900': 'ottogi_cup',
      '8801234567901': 'redbull_250ml',
      '8801234567902': 'monster_355ml',
      '8801234567903': 'seoul_milk_1l',
      '8801234567904': 'yoplait_strawberry_150ml',
      '8801234567905': 'banana_milk_200ml',
      '8801234567906': 'bread_4pack',
      '8801234567907': 'triangle_kimbap_tuna',
      '8801234567908': 'dosirak_bulgogi',
      '8801234567909': 'icecream_vanilla',
    };

    final productId = barcodeToId[barcode];
    if (productId != null) {
      return await getProductById(productId);
    }
    return null;
  }
}
