import 'dart:convert';
import 'package:equatable/equatable.dart';

import '../../product_details/model/product_variant_model.dart';

class AddToCartModel extends Equatable {
  final int quantity;
  final int productId;
  final String image;
  final String slug;
  final String token;
  final String color;
  final String size;
  final int? variantId;
  final Set<ActiveVariantModel> variantItems;
  const AddToCartModel({
    required this.quantity,
    required this.productId,
    required this.image,
    required this.slug,
    required this.token,
    this.color = '',
    this.size = '',
    this.variantId,
    required this.variantItems,
  });

  AddToCartModel copyWith({
    int? quantity,
    int? productId,
    String? image,
    String? slug,
    String? token,
    String? color,
    String? size,
    int? variantId,
    Set<ActiveVariantModel>? variantItems,
  }) {
    return AddToCartModel(
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      image: image ?? this.image,
      slug: slug ?? this.slug,
      token: token ?? this.token,
      color: color ?? this.color,
      size: size ?? this.size,
      variantId: variantId ?? this.variantId,
      variantItems: variantItems ?? this.variantItems,
    );
  }

  Map<String, String> toMap() {
    final result = <String, String>{};

    result.addAll({'quantity': quantity.toString()});
    result.addAll({'product_id': productId.toString()});
    result.addAll({'image': image});
    result.addAll({'slug': slug});
    result.addAll({'token': token});
    if (color.isNotEmpty) result.addAll({'color': color});
    if (size.isNotEmpty) result.addAll({'size': size});
    if ((variantId ?? 0) > 0) result.addAll({'variant_id': variantId.toString()});

    variantItems.toList().asMap().forEach((k, element) {
      if (element.activeVariantsItems.isNotEmpty) {
        result.addAll({'variants[$k]': element.id.toString()});
        result.addAll(
          {'items[$k]': element.activeVariantsItems.first.id.toString()},
        );
      }
    });

    return result;
  }

  factory AddToCartModel.fromMap(Map<String, dynamic> map) {
    return AddToCartModel(
      quantity: map['quantity']?.toInt() ?? 0,
      productId: map['product_id']?.toInt() ?? 0,
      image: map['image'] ?? '',
      slug: map['slug'] ?? '',
      token: map['token'] ?? '',
      variantId: map['variant_id'] != null ? int.tryParse(map['variant_id'].toString()) : null,
      variantItems: const {},
    );
  }

  String toJson() => json.encode(toMap());

  factory AddToCartModel.fromJson(String source) =>
      AddToCartModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AddToCartModel(quantity: $quantity, product_id: $productId, image: $image, slug: $slug, token: $token)';
  }

  @override
  List<Object> get props {
    return [
      quantity,
      productId,
      image,
      slug,
      token,
      color,
      size,
      variantId ?? 0,
      variantItems,
    ];
  }
}
