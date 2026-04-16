import 'dart:convert';

import 'package:equatable/equatable.dart';

class OrderedProductModel extends Equatable {
  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    return double.tryParse(value.toString()) ?? 0;
  }

  static double _resolveUnitPrice(Map<String, dynamic> map) {
    final variantDetails = _parseVariantDetails(map['variant_details']);
    if (variantDetails != null) {
      final variantPrice = _parseDouble(variantDetails['price']);
      if (variantPrice > 0) return variantPrice;
    }

    final variantPrice =
        _parseDouble(map['varient_price'] ?? map['variant_price']);
    if (variantPrice > 0) return variantPrice;

    final unit = _parseDouble(map['unit_price']);
    if (unit > 0) return unit;

    final offer = _parseDouble(map['product_offerprice'] ?? map['offer_price']);
    if (offer > 0) return offer;

    final base = _parseDouble(map['product_price'] ?? map['price']);
    return base;
  }

  static Map<String, dynamic>? _parseVariantDetails(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (_) {}
    }
    return null;
  }

  static String _resolveThumbImage(Map<String, dynamic> map) {
    final variantDetails = _parseVariantDetails(map['variant_details']);
    final variantImageFromDetails = variantDetails?['image']?.toString() ?? '';
    if (variantImageFromDetails.isNotEmpty) return variantImageFromDetails;

    final variantImage =
        (map['variant_image'] ?? map['variantImage'] ?? '').toString();
    if (variantImage.isNotEmpty) return variantImage;

    if (map['cart'] is Map<String, dynamic>) {
      final cartMap = map['cart'] as Map<String, dynamic>;
      final cartVariantImage = (cartMap['variant_image'] ?? '').toString();
      if (cartVariantImage.isNotEmpty) return cartVariantImage;
    }

    if (map['product'] is Map<String, dynamic>) {
      final product = map['product'] as Map<String, dynamic>;
      return (product['thumb_image_url'] ?? product['thumb_image'] ?? '')
          .toString();
    }

    return (map['thumb_image_url'] ?? map['thumb_image'] ?? '').toString();
  }

  static String _parseDisplayString(dynamic value) {
    if (value == null) return '';
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).join(', ');
        }
      } catch (_) {}
      return value;
    }
    return value.toString();
  }

  final int id;
  final int orderId;
  final int productId;
  final int sellerId;
  final String productName;
  final double unitPrice;
  final double vat;
  final int qty;

  final String thumbImage;
  final String slug;
  final String color;
  final String size;
  final String createdAt;
  final String updatedAt;

  const OrderedProductModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.unitPrice,
    required this.vat,
    required this.thumbImage,
    required this.slug,
    this.color = '',
    this.size = '',
    required this.qty,
    required this.createdAt,
    required this.updatedAt,
  });

  OrderedProductModel copyWith({
    int? id,
    int? orderId,
    int? productId,
    int? sellerId,
    String? productName,
    double? unitPrice,
    double? vat,
    int? qty,
    String? thumbImage,
    String? createdAt,
    String? updatedAt,
    String? slug,
    String? color,
    String? size,
  }) {
    return OrderedProductModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      vat: vat ?? this.vat,
      qty: qty ?? this.qty,
      thumbImage: thumbImage ?? this.thumbImage,
      slug: slug ?? this.slug,
      color: color ?? this.color,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'order_id': orderId});
    result.addAll({'product_id': productId});
    result.addAll({'seller_id': sellerId});
    result.addAll({'product_name': productName});
    result.addAll({'unit_price': unitPrice});
    result.addAll({'vat': vat});
    result.addAll({'qty': qty});
    result.addAll({'thumb_image': thumbImage});
    result.addAll({'slug': slug});
    result.addAll({'created_at': createdAt});
    result.addAll({'updated_at': updatedAt});

    return result;
  }

  factory OrderedProductModel.fromMap(Map<String, dynamic> map) {
    return OrderedProductModel(
      id: map['id']?.toInt() ?? 0,
      orderId:
          map['order_id'] != null ? int.parse(map['order_id'].toString()) : 0,
      productId: map['product_id'] != null
          ? int.parse(map['product_id'].toString())
          : 0,
      sellerId:
          map['seller_id'] != null ? int.parse(map['seller_id'].toString()) : 0,
      productName: map['product_name'] ?? '',
      unitPrice: _resolveUnitPrice(map),
      vat: map['vat'] != null ? double.parse(map['vat'].toString()) : 0,
      qty: map['qty'] != null ? int.parse(map['qty'].toString()) : 0,
      thumbImage: _resolveThumbImage(map),
      slug: map['product'] != null
          ? (map['product']['slug'] ?? '')
          : (map['slug'] ?? ''),
      color: _parseDisplayString(
          map['cart'] != null ? map['cart']['color'] : map['color']),
      size: _parseDisplayString(
          map['cart'] != null ? map['cart']['size'] : map['size']),
      createdAt: map['created_at'] ?? '',
      updatedAt: map['updated_at'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory OrderedProductModel.fromJson(String source) =>
      OrderedProductModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'OrderedProductModel(id: $id, order_id: $orderId, product_id: $productId, seller_id: $sellerId, product_name: $productName, unit_price: $unitPrice, vat: $vat, qty: $qty,  created_at: $createdAt, updated_at: $updatedAt)';
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        sellerId,
        productName,
        unitPrice,
        vat,
        qty,
        thumbImage,
        slug,
        color,
        size,
        createdAt,
        updatedAt
      ];
}
