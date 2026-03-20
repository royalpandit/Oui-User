import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/favorite_button.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../home/model/product_model.dart';
import '../../../utils/utils.dart';
import '../../setting/model/website_setup_model.dart';
import '../../category/component/price_card_widget.dart';

class FeaturedHighlightCard extends StatelessWidget {
  const FeaturedHighlightCard({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final appSetting = context.read<AppSettingCubit>();
    final priceData = _calcPrice(appSetting);

    return Semantics(
      label: 'Featured: ${product.name}, rated ${product.rating.toStringAsFixed(1)} stars',
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.productDetailsScreen,
          arguments: product.slug,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          height: 420,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImage(
                    path: RemoteUrls.imageUrl(product.thumbImage),
                    fit: BoxFit.cover,
                  ),
                  // Bottom gradient for text overlap
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            const Color(0xFF1B1B1B),
                            const Color(0xFF1B1B1B).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: FavoriteButton(productId: product.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE2E2E2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (product.shortDescription.isNotEmpty)
                    Text(
                      product.shortDescription,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF919191),
                        height: 1.4,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      PriceCardWidget(
                        price: priceData['mainPrice']!,
                        offerPrice: priceData['offerPrice']!,
                        textSize: 18,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFFFC107), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF919191),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Map<String, String> _calcPrice(AppSettingCubit appSetting) {
    double offerPrice = 0.0;
    double mainPrice = 0.0;
    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: product.id));

    if (product.offerPrice.toString().isNotEmpty) {
      if (product.productVariants.isNotEmpty) {
        double p = 0.0;
        for (var i in product.productVariants) {
          if (i.activeVariantsItems.isNotEmpty) {
            p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
          }
        }
        offerPrice = p + product.offerPrice;
      } else {
        offerPrice = product.offerPrice;
      }
    }
    if (product.productVariants.isNotEmpty) {
      double p = 0.0;
      for (var i in product.productVariants) {
        if (i.activeVariantsItems.isNotEmpty) {
          p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
        }
      }
      mainPrice = p + product.price;
    } else {
      mainPrice = product.price;
    }

    if (isFlashSale) {
      if (product.offerPrice.toString().isNotEmpty) {
        final discount =
            appSetting.settingModel!.flashSale.offer / 100 * offerPrice;
        return {
          'mainPrice': mainPrice.toString(),
          'offerPrice': (offerPrice - discount).toString(),
        };
      } else {
        final discount =
            appSetting.settingModel!.flashSale.offer / 100 * mainPrice;
        return {
          'mainPrice': mainPrice.toString(),
          'offerPrice': (mainPrice - discount).toString(),
        };
      }
    }

    return {
      'mainPrice': mainPrice.toString(),
      'offerPrice': offerPrice.toString(),
    };
  }
}
