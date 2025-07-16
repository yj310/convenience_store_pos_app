// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  price: (json['price'] as num).toInt(),
  promotionType: json['promotionType'] as String?,
  promotionGroup: json['promotionGroup'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'price': instance.price,
  'promotionType': instance.promotionType,
  'promotionGroup': instance.promotionGroup,
  'note': instance.note,
};
