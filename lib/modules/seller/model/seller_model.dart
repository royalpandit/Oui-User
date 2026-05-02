// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../home/model/brand_model.dart';
import '../../home/model/product_model.dart';
import '../../product_details/model/product_variant_model.dart';
import 'seller_order_product_model.dart';
import 'single_seller_model.dart';

class SellerProductModel extends Equatable {
  final List<ActiveVariantModel> activeVariants;
  final SingleSellerModel singleSellerModel;
  final List<BrandModel> brands;
  final List<ProductModel> products;
  final List<SellerOrderProductModel> orderProducts;

  const SellerProductModel({
    required this.activeVariants,
    required this.singleSellerModel,
    required this.brands,
    required this.products,
    this.orderProducts = const [],
  });

  SellerProductModel copyWith({
    List<ActiveVariantModel>? activeVariants,
    SingleSellerModel? singleSellerModel,
    List<BrandModel>? brands,
    List<ProductModel>? products,
    List<SellerOrderProductModel>? orderProducts,
  }) {
    return SellerProductModel(
      activeVariants: activeVariants ?? this.activeVariants,
      singleSellerModel: singleSellerModel ?? this.singleSellerModel,
      brands: brands ?? this.brands,
      products: products ?? this.products,
      orderProducts: orderProducts ?? this.orderProducts,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'activeVariants': activeVariants.map((x) => x.toMap()).toList(),
      'seller': singleSellerModel.toMap(),
      'brands': brands.map((x) => x.toMap()).toList(),
      'products': products.map((x) => x.toMap()).toList(),
      'orderProducts': orderProducts.map((x) => x.toMap()).toList(),
    };
  }

  factory SellerProductModel.fromMap(Map<String, dynamic> map) {
    final rawActiveVariants = map['activeVariants'] ?? map['active_variants'];
    final rawSeller = map['seller'] ?? map['singleSeller'] ?? const {};
    final rawProducts = map['products'];
    final rawBrands = map['brands'];
    final rawOrderProducts = map['orderProducts'];

    final List<dynamic> productList = rawProducts is Map<String, dynamic>
        ? (rawProducts['data'] as List? ?? const [])
        : (rawProducts as List? ?? const []);

    return SellerProductModel(
      activeVariants: rawActiveVariants is List
          ? List<ActiveVariantModel>.from(
              rawActiveVariants.map<ActiveVariantModel>(
                (x) => ActiveVariantModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : const [],
      singleSellerModel: SingleSellerModel.fromMap(
        rawSeller is Map<String, dynamic> ? rawSeller : const {},
      ),
      brands: rawBrands is List
          ? List<BrandModel>.from(
              rawBrands.map<BrandModel>(
                (x) => BrandModel.fromMap(x as Map<String, dynamic>),
              ),
            )
          : const [],
      products: List<ProductModel>.from(
        productList.map<ProductModel>(
          (x) => ProductModel.fromMap(x as Map<String, dynamic>),
        ),
      ),
      orderProducts: rawOrderProducts is List
          ? List<SellerOrderProductModel>.from(
              rawOrderProducts.map<SellerOrderProductModel>(
                (x) => SellerOrderProductModel.fromMap(
                  x as Map<String, dynamic>,
                ),
              ),
            )
          : const [],
    );
  }

  String toJson() => json.encode(toMap());

  factory SellerProductModel.fromJson(String source) =>
      SellerProductModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props =>
      [activeVariants, singleSellerModel, brands, products, orderProducts];
}
