import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/widgets/capitalized_word.dart';
import 'package:shop_us/widgets/favorite_button.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../category/component/price_card_widget.dart';
import '../../setting/model/website_setup_model.dart';
import '../model/product_model.dart';

class HomeHorizontalListProductCard extends StatelessWidget {
  final ProductModel productModel;
  final double height, width;

  const HomeHorizontalListProductCard({
    super.key,
    this.height = 140, // Reduced slightly for a tighter professional look
    this.width = 280,
    required this.productModel,
  });

  @override
  Widget build(BuildContext context) {
    final appSetting = context.read<AppSettingCubit>();
    double flashPrice = 0.0;
    double offerPrice = 0.0;
    double mainPrice = 0.0;

    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: productModel.id));

    // Price Calculation Logic
    if (productModel.offerPrice.toString().isNotEmpty) {
      double p = 0.0;
      if (productModel.productVariants.isNotEmpty) {
        for (var i in productModel.productVariants) {
          if (i.activeVariantsItems.isNotEmpty) {
            p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
          }
        }
        offerPrice = p + double.parse(productModel.offerPrice.toString());
      } else {
        offerPrice = double.parse(productModel.offerPrice.toString());
      }
    }
    if (productModel.productVariants.isNotEmpty) {
      double p = 0.0;
      for (var i in productModel.productVariants) {
        if (i.activeVariantsItems.isNotEmpty) {
          p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
        }
      }
      mainPrice = p + double.parse(productModel.price.toString());
    } else {
      mainPrice = double.parse(productModel.price.toString());
    }

    if (isFlashSale) {
      final discount = appSetting.settingModel!.flashSale.offer /
          100 *
          (productModel.offerPrice.toString().isNotEmpty
              ? offerPrice
              : mainPrice);
      flashPrice = (productModel.offerPrice.toString().isNotEmpty
              ? offerPrice
              : mainPrice) -
          discount;
    }

    return Container(
      height: height,
      width: width,
      margin: const EdgeInsets.only(right: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1B1B),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, RouteNames.productDetailsScreen,
            arguments: productModel.slug),
        child: Row(
          children: [
            // 1. Left Side: Image Section
            _buildImageSection(),

            // 2. Right Side: Info Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rating
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFFC107), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          productModel.rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF919191)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Title
                    AutoSizeText(
                      productModel.name.capitalizeByWord(),
                      maxLines: 2,
                      minFontSize: 13,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE2E2E2),
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Price
                    PriceCardWidget(
                      price: mainPrice.toString(),
                      offerPrice: isFlashSale
                          ? flashPrice.toString()
                          : offerPrice.toString(),
                    ),
                    const SizedBox(height: 6),
                    Builder(
                      builder: (_) {
                        final codes = _colorCodes();
                        if (codes.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: codes.take(4).map((code) {
                              return Container(
                                width: 10,
                                height: 10,
                                margin: const EdgeInsets.only(right: 5),
                                decoration: BoxDecoration(
                                  color: _parseColorCode(code),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF585858), width: 0.5),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _colorCodes() {
    final codes = <String>[];
    final seen = <String>{};
    for (final item in productModel.variantDetails) {
      final code = item.colorCode.trim();
      final key = (code.isNotEmpty ? code : item.color).trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      codes.add(code);
    }
    return codes;
  }

  Color _parseColorCode(String code) {
    final raw = code.trim();
    if (raw.isEmpty) return const Color(0xFF7A7A7A);
    String hex = raw.startsWith('#') ? raw.substring(1) : raw;
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xFF7A7A7A);
    return Color(value);
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          width: width * 0.38,
          height: height,
          decoration: const BoxDecoration(
            color: Color(0xFF262626),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: CustomImage(
              path: RemoteUrls.imageUrl(productModel.thumbImage),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: FavoriteButton(productId: productModel.id),
        ),
      ],
    );
  }
}