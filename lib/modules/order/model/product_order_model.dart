import 'dart:convert';

import 'package:equatable/equatable.dart';

class OrderedProductModel extends Equatable {
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
      unitPrice: map['unit_price'] != null
          ? double.parse(map['unit_price'].toString())
          : 0,
      vat: map['vat'] != null ? double.parse(map['vat'].toString()) : 0,
      qty: map['qty'] != null ? int.parse(map['qty'].toString()) : 0,
      thumbImage: map['product'] != null
          ? (map['product']['thumb_image_url'] ?? map['product']['thumb_image'] ?? '')
          : (map['thumb_image_url'] ?? map['thumb_image'] ?? ''),
      slug: map['product'] != null
          ? (map['product']['slug'] ?? '')
          : (map['slug'] ?? ''),
      color: _parseDisplayString(map['color']),
      size: _parseDisplayString(map['size']),
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
