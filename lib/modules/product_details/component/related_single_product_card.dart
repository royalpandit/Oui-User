import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
      decoration: const BoxDecoration(
        color: Color(0xFF1B1B1B),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                color: Color(0xFF171717),
              ),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, RouteNames.productDetailsScreen,
                        arguments: productModel.slug),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CustomImage(
                          path: RemoteUrls.imageUrl(productModel.thumbImage),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8.0,
                    top: 8.0,
                    child: FavoriteButton(
                      productId: productModel.id,
                      productSlug: productModel.slug,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildContent(context, appSetting),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppSettingCubit appSetting) {
    double flashPrice = 0.0;
    double offerPrice = 0.0;
    double mainPrice = 0.0;
    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: productModel.id));

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
      final discount = appSetting.settingModel!.flashSale.offer /
          100 *
          (productModel.offerPrice.toString().isNotEmpty
              ? offerPrice
              : mainPrice);
      flashPrice =
          (productModel.offerPrice.toString().isNotEmpty
                  ? offerPrice
                  : mainPrice) -
              discount;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(
            productModel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFE2E2E2),
              letterSpacing: 0.6,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 4),
          PriceCardWidget(
            price: mainPrice.toString(),
            offerPrice: isFlashSale
                ? flashPrice.toString()
                : offerPrice.toString(),
            textSize: 14,
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              final addToCart = AddToCartModel(
                quantity: 1,
                productId: productModel.id,
                image: productModel.thumbImage,
                slug: productModel.slug,
                token: "",
                variantItems: variantItems,
              );
              context.read<AddToCartCubit>().addToCart(addToCart);
            },
            child: Text(
              'ADD TO CART',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF919191),
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}