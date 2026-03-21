import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'cart_product_model.dart';

class CartResponseModel extends Equatable {
  final List<CartProductModel> cartProducts;
  final int? vendorUserId;

  const CartResponseModel({
    required this.cartProducts,
    this.vendorUserId,
  });

  CartResponseModel copyWith({
    List<CartProductModel>? cartProducts,
    int? vendorUserId,
  }) {
    return CartResponseModel(
      cartProducts: cartProducts ?? this.cartProducts,
      vendorUserId: vendorUserId ?? this.vendorUserId,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};
    result.addAll({'cartProducts': cartProducts.map((x) => x.toMap()).toList()});
    if (vendorUserId != null) {
      result.addAll({'vendor_detail': {'user_id': vendorUserId}});
    }
    return result;
  }

  factory CartResponseModel.fromMap(Map<String, dynamic> map) {
    int? vendorUserId;
    if (map['vendor_detail'] != null && map['vendor_detail'] is Map) {
      vendorUserId = map['vendor_detail']['user_id'] != null
          ? int.tryParse(map['vendor_detail']['user_id'].toString())
          : null;
    }
    return CartResponseModel(
      cartProducts: List<CartProductModel>.from(
          map['cartProducts']?.map((x) => CartProductModel.fromMap(x))),
      vendorUserId: vendorUserId,
    );
  }

  String toJson() => json.encode(toMap());

  factory CartResponseModel.fromJson(String source) =>
      CartResponseModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'CartResponseModel(cartProducts: $cartProducts, vendorUserId: $vendorUserId)';

  @override
  List<Object?> get props => [cartProducts, vendorUserId];
}
