import 'package:equatable/equatable.dart';

sealed class Promotion extends Equatable {
  const Promotion();

  String get type;
  String get group;
}

class BuyOneGetOnePromotion extends Promotion {
  const BuyOneGetOnePromotion({required this.group});

  @override
  String get type => '1+1';

  @override
  final String group;

  @override
  List<Object?> get props => [type, group];
}

class BuyTwoGetOnePromotion extends Promotion {
  const BuyTwoGetOnePromotion({required this.group});

  @override
  String get type => '2+1';

  @override
  final String group;

  @override
  List<Object?> get props => [type, group];
}

class FreeGiftPromotion extends Promotion {
  const FreeGiftPromotion({required this.group, required this.giftProductId});

  @override
  String get type => 'free_gift';

  @override
  final String group;
  final String giftProductId;

  @override
  List<Object?> get props => [type, group, giftProductId];
}

class FixedPricePromotion extends Promotion {
  const FixedPricePromotion({required this.group, required this.fixedPrice});

  @override
  String get type => 'fixed_price';

  @override
  final String group;
  final int fixedPrice;

  @override
  List<Object?> get props => [type, group, fixedPrice];
}
