// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import '/modules/home/model/product_model.dart';
import 'varient_model.dart';

class CartProductModel extends Equatable {
  final int id;
  final int productId;
  final int qty;
  final int variantId;
  final double variantPriceAdjustment;
  final ProductModel product;
  final List<String> selectedSizes;
  final List<String> selectedColors;

  final List<VariantModel> variants;

  const CartProductModel({
    required this.id,
    required this.productId,
    required this.qty,
    this.variantId = 0,
    this.variantPriceAdjustment = 0,
    required this.product,
    this.selectedSizes = const [],
    this.selectedColors = const [],
    required this.variants,
  });

  CartProductModel copyWith({
    int? id,
    int? productId,
    int? qty,
    int? variantId,
    double? variantPriceAdjustment,
    ProductModel? product,
    List<String>? selectedSizes,
    List<String>? selectedColors,
    List<VariantModel>? variants,
  }) {
    return CartProductModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      qty: qty ?? this.qty,
      variantId: variantId ?? this.variantId,
      variantPriceAdjustment:
          variantPriceAdjustment ?? this.variantPriceAdjustment,
      product: product ?? this.product,
      selectedSizes: selectedSizes ?? this.selectedSizes,
      selectedColors: selectedColors ?? this.selectedColors,
      variants: variants ?? this.variants,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {
        return [value];
      }
    }
    return [];
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'product_id': productId,
      'qty': qty,
      'variant_id': variantId,
      'varient_price': variantPriceAdjustment,
      'product': product.toMap(),
      'size': selectedSizes,
      'color': selectedColors,
      'variants': variants.map((x) => x.toMap()).toList(),
    };
  }

  factory CartProductModel.fromMap(Map<String, dynamic> map) {
    final dynamic variantsRaw = map['variants'];
    final List<VariantModel> parsedVariants = variantsRaw is List
        ? variantsRaw
            .map((x) => VariantModel.fromMap(x as Map<String, dynamic>))
            .toList()
        : <VariantModel>[];

    final dynamic rawProduct = map['product'];
    final Map<String, dynamic> productMap = rawProduct is Map<String, dynamic>
        ? <String, dynamic>{
            ...rawProduct,
            if ((map['variant_image']?.toString().isNotEmpty ?? false))
              'thumb_image': map['variant_image'],
          }
        : <String, dynamic>{
            'id': map['product_id'] ?? 0,
            'name': map['product_name'] ?? '',
            'short_name': map['product_name'] ?? '',
            'slug': map['slug'] ?? '',
            'thumb_image': map['variant_image'] ??
                map['product_image'] ??
                map['thumb_image'] ??
                map['thumb_image_url'] ??
                '',
            'price': map['product_price'] ?? map['price'] ?? 0,
            'offer_price': map['product_offerprice'] ?? map['offer_price'] ?? 0,
            'qty': map['qty'] ?? 0,
            'vendor_id': map['vendor_id'] ?? 0,
            'category_id': map['category_id'] ?? 0,
            'brand_id': map['brand_id'] ?? 0,
            'averageRating': map['averageRating'] ?? '0',
            'varient_item_details': const [],
          };

    return CartProductModel(
      id: map['id'] != null ? int.parse(map['id'].toString()) : 0,
      productId: map['product_id'] != null
          ? int.parse(map['product_id'].toString())
          : 0,
      qty: map['qty'] != null ? int.parse(map['qty'].toString()) : 0,
      variantId: map['variant_id'] != null
          ? int.parse(map['variant_id'].toString())
          : 0,
      variantPriceAdjustment:
          _parseDouble(map['varient_price'] ?? map['variant_price']),
      product: ProductModel.fromMap(productMap),
      selectedSizes: _parseStringList(map['size']),
      selectedColors: _parseStringList(map['color']),
      variants: parsedVariants,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartProductModel.fromJson(String source) =>
      CartProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      productId,
      qty,
      variantId,
      variantPriceAdjustment,
      product,
      selectedSizes,
      selectedColors,
      variants,
    ];
  }
}
