import 'package:convenience_store_pos_app/data/data_source/product_data_source.dart';
import 'package:convenience_store_pos_app/data/repository/product_repository_impl.dart';
import 'package:convenience_store_pos_app/domain/model/promotion.dart';
import 'package:convenience_store_pos_app/domain/promotion/promotion_pipeline.dart';
import 'package:convenience_store_pos_app/presentation/bloc/cart_bloc.dart';
import 'package:convenience_store_pos_app/presentation/pages/pos_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '편의점 POS 시스템',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) {
          // 의존성 주입 설정
          final productDataSource = MockProductDataSource();
          final productRepository = ProductRepositoryImpl(productDataSource);

          // 프로모션 파이프라인 설정
          final promotionPipeline = PromotionPipeline(
            promotions: [
              const BuyOneGetOnePromotion(group: 'beverage'),
              const BuyOneGetOnePromotion(group: 'coffee'),
              const BuyTwoGetOnePromotion(group: 'snack'),
              const FreeGiftPromotion(
                group: 'water',
                giftProductId: 'nongshim_cup',
              ),
              const FixedPricePromotion(
                group: 'energy_redbull',
                fixedPrice: 2000,
              ),
              const FixedPricePromotion(
                group: 'energy_monster',
                fixedPrice: 2200,
              ),
            ],
          );

          return CartBloc(
            productRepository: productRepository,
            promotionPipeline: promotionPipeline,
          );
        },
        child: const PosPage(),
      ),
    );
  }
}
