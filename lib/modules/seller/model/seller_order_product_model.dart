import 'dart:convert';

import 'package:equatable/equatable.dart';

class SellerOrderProductModel extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final int sellerId;
  final String productName;
  final double unitPrice;
  final int qty;

  const SellerOrderProductModel({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.sellerId,
    required this.productName,
    required this.unitPrice,
    required this.qty,
  });

  factory SellerOrderProductModel.fromMap(Map<String, dynamic> map) {
    return SellerOrderProductModel(
      id: map['id'] != null ? int.tryParse(map['id'].toString()) ?? 0 : 0,
      orderId: map['order_id'] != null
          ? int.tryParse(map['order_id'].toString()) ?? 0
          : 0,
      productId: map['product_id'] != null
          ? int.tryParse(map['product_id'].toString()) ?? 0
          : 0,
      sellerId: map['seller_id'] != null
          ? int.tryParse(map['seller_id'].toString()) ?? 0
          : 0,
      productName: map['product_name']?.toString() ?? '',
      unitPrice: map['unit_price'] != null
          ? double.tryParse(map['unit_price'].toString()) ?? 0
          : 0,
      qty: map['qty'] != null ? int.tryParse(map['qty'].toString()) ?? 0 : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'seller_id': sellerId,
      'product_name': productName,
      'unit_price': unitPrice,
      'qty': qty,
    };
  }

  String toJson() => json.encode(toMap());

  factory SellerOrderProductModel.fromJson(String source) =>
      SellerOrderProductModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  @override
  List<Object> get props {
    return [id, orderId, productId, sellerId, productName, unitPrice, qty];
  }
}
