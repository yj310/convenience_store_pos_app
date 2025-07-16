import 'package:json_annotation/json_annotation.dart';
import '../../domain/model/product.dart';

part 'product_dto.g.dart';

@JsonSerializable()
class ProductDto {
  final String id;
  final String name;
  final String category;
  final int price;
  @JsonKey(name: 'promotion_type')
  final String? promotionType;
  @JsonKey(name: 'promotion_group')
  final String? promotionGroup;
  final String? note;

  const ProductDto({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.promotionType,
    this.promotionGroup,
    this.note,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) =>
      _$ProductDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProductDtoToJson(this);

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      category: category,
      price: price,
      promotionType: promotionType,
      promotionGroup: promotionGroup,
      note: note,
    );
  }
}
