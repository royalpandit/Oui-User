import 'dart:convert';

import 'package:equatable/equatable.dart';

class VariantDetailModel extends Equatable {
  final int id;
  final int productId;
  final String name;
  final String color;
  final String colorCode;
  final String size;
  final int qty;
  final double price;
  final String image;
  final int isPrimary;

  const VariantDetailModel({
    required this.id,
    required this.productId,
    required this.name,
    required this.color,
    required this.colorCode,
    required this.size,
    required this.qty,
    this.price = 0,
    required this.image,
    this.isPrimary = 0,
  });

  VariantDetailModel copyWith({
    int? id,
    int? productId,
    String? name,
    String? color,
    String? colorCode,
    String? size,
    int? qty,
    double? price,
    String? image,
    int? isPrimary,
  }) {
    return VariantDetailModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      color: color ?? this.color,
      colorCode: colorCode ?? this.colorCode,
      size: size ?? this.size,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      image: image ?? this.image,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'product_id': productId,
      'name': name,
      'color': color,
      'color_code': colorCode,
      'size': size,
      'qty': qty,
      'price': price,
      'image': image,
      'is_primary': isPrimary,
    };
  }

  factory VariantDetailModel.fromMap(Map<String, dynamic> map) {
    return VariantDetailModel(
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      productId: map['product_id'] != null
          ? int.parse(map['product_id'].toString())
          : 0,
      name: map['name']?.toString() ?? '',
      color: map['color']?.toString() ?? '',
      colorCode: map['color_code']?.toString() ?? '',
      size: map['size']?.toString() ?? '',
      qty: map['qty'] != null ? int.parse(map['qty'].toString()) : 0,
      price: map['price'] != null
          ? double.tryParse(map['price'].toString()) ?? 0
          : (map['varient_price'] != null
              ? double.tryParse(map['varient_price'].toString()) ?? 0
              : 0),
      image: map['image']?.toString() ?? '',
      isPrimary: map['is_primary'] != null
          ? int.tryParse(map['is_primary'].toString()) ?? 0
          : 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory VariantDetailModel.fromJson(String source) =>
      VariantDetailModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object> get props =>
      [id, productId, name, color, colorCode, size, qty, price, image, isPrimary];
}
