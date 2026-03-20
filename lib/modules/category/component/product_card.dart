import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/cart/controllers/cart/add_to_cart/add_to_cart_cubit.dart';
import '/modules/cart/model/add_to_cart_model.dart';
import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/favorite_button.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../home/model/product_model.dart';
import '../../product_details/model/product_variant_model.dart';
import '../../setting/model/website_setup_model.dart';
import 'price_card_widget.dart';

class ProductCard extends StatelessWidget {
  final ProductModel productModel;
  final double? width;

  ProductCard({
    super.key,
    required this.productModel,
    this.width,
  });

  final Set<ActiveVariantModel> variantItems = {};

  @override
  Widget build(BuildContext context) {
    final appSetting = context.read<AppSettingCubit>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: width,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF0F0F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                      context, RouteNames.productDetailsScreen,
                      arguments: productModel.slug),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(productModel.thumbImage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                    bottom: 0.0, right: 0.0, child: addToCartButton(context)),
                Positioned(
                    left: 10.0,
                    top: 10.0,
                    child: FavoriteButton(productId: productModel.id))
              ],
            ),
          ),
        ),
        _buildContent(appSetting),
      ],
    );
  }

  Widget addToCartButton(BuildContext context) {
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
        height: 36,
        width: 36,
        alignment: Alignment.center,
        margin: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.black,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildContent(AppSettingCubit appSetting) {
    double flashPrice = 0.0;
    double offerPrice = 0.0;
    double mainPrice = 0.0;
    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: productModel.id));

    if (productModel.offerPrice.toString().isNotEmpty) {
      if (productModel.productVariants.isNotEmpty) {
        double p = 0.0;
        for (var i in productModel.productVariants) {
          if (i.activeVariantsItems.isNotEmpty) {
            p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
          }
        }
        offerPrice = p + productModel.offerPrice;
      } else {
        offerPrice = productModel.offerPrice;
      }
    }
    if (productModel.productVariants.isNotEmpty) {
      double p = 0.0;
      for (var i in productModel.productVariants) {
        if (i.activeVariantsItems.isNotEmpty) {
          p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
        }
      }
      mainPrice = p + productModel.price;
    } else {
      mainPrice = productModel.price;
    }

    if (isFlashSale) {
      if (productModel.offerPrice.toString().isNotEmpty) {
        final discount =
            appSetting.settingModel!.flashSale.offer / 100 * offerPrice;

        flashPrice = offerPrice - discount;
      } else {
        final discount =
            appSetting.settingModel!.flashSale.offer / 100 * mainPrice;

        flashPrice = mainPrice - discount;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 6, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 13),
              const SizedBox(width: 3),
              Text(
                productModel.rating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            productModel.name.length > 10
                ? '${productModel.name.substring(0, 10)}...'
                : productModel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          if (isFlashSale) ...[
            PriceCardWidget(
              price: mainPrice.toString(),
              offerPrice: flashPrice.toString(),
              textSize: 14,
            ),
          ] else ...[
            PriceCardWidget(
              price: mainPrice.toString(),
              offerPrice: offerPrice.toString(),
              textSize: 14,
            ),
          ],
        ],
      ),
    );
  }
}
