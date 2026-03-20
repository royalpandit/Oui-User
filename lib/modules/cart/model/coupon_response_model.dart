// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class CouponResponseModel extends Equatable {
  final int id;
  final int sellerId;
  final String name;
  final String code;
  final String offerType;
  final String discount;
  final String maxQuantity;
  final String expiredDate;
  final String minPurchasePrice;
  final String applyQty;
  final String status;
  final String createdAt;
  final String updatedAt;

  const CouponResponseModel({
    required this.id,
    required this.sellerId,
    required this.name,
    required this.code,
    required this.offerType,
    required this.discount,
    required this.maxQuantity,
    required this.expiredDate,
    required this.applyQty,
    required this.minPurchasePrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  CouponResponseModel copyWith({
    int? id,
    int? sellerId,
    String? name,
    String? code,
    String? offerType,
    String? discount,
    String? maxQuantity,
    String? expiredDate,
    String? minPurchasePrice,
    String? applyQty,
    String? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return CouponResponseModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      name: name ?? this.name,
      code: code ?? this.code,
      offerType: offerType ?? this.offerType,
      discount: discount ?? this.discount,
      maxQuantity: maxQuantity ?? this.maxQuantity,
      expiredDate: expiredDate ?? this.expiredDate,
      applyQty: applyQty ?? this.applyQty,
      minPurchasePrice: minPurchasePrice ?? this.minPurchasePrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'seller_id': sellerId,
      'name': name,
      'code': code,
      'offer_type': offerType,
      'discount': discount,
      'max_quantity': maxQuantity,
      'expired_date': expiredDate,
      'apply_qty': applyQty,
      'min_purchase_price': minPurchasePrice,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory CouponResponseModel.fromMap(Map<String, dynamic> map) {
    return CouponResponseModel(
      id: map['id'] ?? 0,
      sellerId: map['seller_id'] != null ? int.parse(map['seller_id'].toString()) : 0,
      name: map['name'] ?? "",
      code: map['code'] ?? "",
      offerType: map['offer_type']?.toString() ?? "",
      discount: map['discount']?.toString() ?? "",
      maxQuantity: map['max_quantity']?.toString() ?? "",
      expiredDate: map['expired_date'] ?? "",
      minPurchasePrice: map['min_purchase_price']?.toString() ?? "",
      applyQty: map['apply_qty']?.toString() ?? "",
      status: map['status']?.toString() ?? "",
      createdAt: map['created_at'] ?? "",
      updatedAt: map['updated_at'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory CouponResponseModel.fromJson(String source) =>
      CouponResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props {
    return [
      id,
      sellerId,
      name,
      code,
      offerType,
      discount,
      maxQuantity,
      expiredDate,
      applyQty,
      minPurchasePrice,
      status,
      createdAt,
      updatedAt,
    ];
  }
}
