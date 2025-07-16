// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDto _$ProductDtoFromJson(Map<String, dynamic> json) => ProductDto(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  price: (json['price'] as num).toInt(),
  promotionType: json['promotion_type'] as String?,
  promotionGroup: json['promotion_group'] as String?,
  note: json['note'] as String?,
);

Map<String, dynamic> _$ProductDtoToJson(ProductDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'price': instance.price,
      'promotion_type': instance.promotionType,
      'promotion_group': instance.promotionGroup,
      'note': instance.note,
    };
