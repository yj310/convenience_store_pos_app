import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product extends Equatable {
  final String id;
  final String name;
  final String category;
  final int price;
  final String? promotionType;
  final String? promotionGroup;
  final String? note;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.promotionType,
    this.promotionGroup,
    this.note,
  });

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    price,
    promotionType,
    promotionGroup,
    note,
  ];
}
