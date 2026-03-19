import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/widgets/capitalized_word.dart';

import '/modules/category/component/price_card_widget.dart';
import '/widgets/favorite_button.dart';
import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../cart/controllers/cart/add_to_cart/add_to_cart_cubit.dart';
import '../../cart/model/add_to_cart_model.dart';
import '../../setting/model/website_setup_model.dart';
import '../model/product_details_product_model.dart';
import '../model/product_variant_model.dart';

class RelatedSingleProductCard extends StatelessWidget {
  final ProductDetailsProductModel productModel;
  final double? width;

  RelatedSingleProductCard({super.key, required this.productModel, this.width});

  final Set<ActiveVariantModel> variantItems = {};

  @override
  Widget build(BuildContext context) {
    final appSetting = context.read<AppSettingCubit>();

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Image Section: Proportional and Contained
          AspectRatio(
            aspectRatio: 1.0, // Ensures a perfect square container
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Product Image
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, RouteNames.productDetailsScreen,
                        arguments: productModel.slug),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), // Padding to keep image from edges
                        child: CustomImage(
                          path: RemoteUrls.imageUrl(productModel.thumbImage),
                          fit: BoxFit.contain, // ✅ Image will never be cut
                        ),
                      ),
                    ),
                  ),
                  
                  // Favorite Button
                  Positioned(
                    left: 8.0,
                    top: 8.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: FavoriteButton(productId: productModel.id),
                    ),
                  ),

                  // Add to Cart Button
                  Positioned(
                    bottom: 8.0,
                    right: 8.0,
                    child: _buildAddToCartButton(context),
                  ),
                ],
              ),
            ),
          ),
          
          // 2. Content Section
          _buildContent(appSetting),
        ],
      ),
    );
  }

  Widget _buildContent(AppSettingCubit appSetting) {
    double flashPrice = 0.0;
    double offerPrice = 0.0;
    double mainPrice = 0.0;
    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: productModel.id));

    // Price logic 
    if (productModel.offerPrice.toString().isNotEmpty) {
      if (productModel.activeVariantModel.isNotEmpty) {
        double p = 0.0;
        for (var i in productModel.activeVariantModel) {
          if (i.activeVariantsItems.isNotEmpty) {
            p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
          }
        }
        offerPrice = p + productModel.offerPrice;
      } else {
        offerPrice = productModel.offerPrice;
      }
    }
    if (productModel.activeVariantModel.isNotEmpty) {
      double p = 0.0;
      for (var i in productModel.activeVariantModel) {
        if (i.activeVariantsItems.isNotEmpty) {
          p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
        }
      }
      mainPrice = p + productModel.price;
    } else {
      mainPrice = productModel.price;
    }

    if (isFlashSale) {
      final discount = appSetting.settingModel!.flashSale.offer / 100 * (productModel.offerPrice.toString().isNotEmpty ? offerPrice : mainPrice);
      flashPrice = (productModel.offerPrice.toString().isNotEmpty ? offerPrice : mainPrice) - discount;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            productModel.name.capitalizeByWord(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          PriceCardWidget(
            price: mainPrice.toString(),
            offerPrice: isFlashSale ? flashPrice.toString() : offerPrice.toString(),
            textSize: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final AddToCartModel addToCart = AddToCartModel(
          quantity: 1,
          productId: productModel.id,
          image: productModel.thumbImage,
          slug: productModel.slug,
          token: "",
          variantItems: variantItems,
        );
        context.read<AddToCartCubit>().addToCart(addToCart);
      },
      child: Container(
        height: 32,
        width: 32,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}