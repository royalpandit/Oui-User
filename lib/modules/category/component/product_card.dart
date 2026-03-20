import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/favorite_button.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../home/model/product_model.dart';
import '../../setting/model/website_setup_model.dart';
import 'price_card_widget.dart';

class ProductCard extends StatelessWidget {
  final ProductModel productModel;
  final double? width;

  const ProductCard({
    super.key,
    required this.productModel,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final appSetting = context.read<AppSettingCubit>();
    return Semantics(
      label: '${productModel.name}, rated ${productModel.rating.toStringAsFixed(1)} stars',
      button: true,
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          color: Color(0xFF1B1B1B),
          border: Border.fromBorderSide(
            BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                        context, RouteNames.productDetailsScreen,
                        arguments: productModel.slug),
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(productModel.thumbImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: FavoriteButton(productId: productModel.id),
                  ),
                ],
              ),
            ),
            _buildContent(appSetting),
          ],
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
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productModel.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: const Color(0xFFE2E2E2),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 12),
              const SizedBox(width: 3),
              Text(
                productModel.rating.toStringAsFixed(1),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                  color: const Color(0xFF919191),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
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