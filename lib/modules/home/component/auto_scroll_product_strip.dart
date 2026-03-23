import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../widgets/custom_image.dart';
import '../../../utils/utils.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../home/model/product_model.dart';
import '../../setting/model/website_setup_model.dart';
import '../../category/component/price_card_widget.dart';

class AutoScrollProductStrip extends StatefulWidget {
  const AutoScrollProductStrip({
    super.key,
    required this.products,
    this.title = '',
    this.onViewAll,
  });

  final List<ProductModel> products;
  final String title;
  final VoidCallback? onViewAll;

  @override
  State<AutoScrollProductStrip> createState() =>
      _AutoScrollProductStripState();
}

class _AutoScrollProductStripState extends State<AutoScrollProductStrip>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animController;
  bool _userScrolling = false;
  static const double _cardWidth = 200.0;
  static const double _cardSpacing = 14.0;
  static const double _scrollSpeed = 0.3; // pixels per frame tick

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // looping ticker
    )..addListener(_onTick);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.repeat();
    });
  }

  void _onTick() {
    if (_userScrolling || !_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    if (current >= max) {
      _scrollController.jumpTo(0);
    } else {
      _scrollController.jumpTo(current + _scrollSpeed);
    }
  }

  @override
  void dispose() {
    _animController.removeListener(_onTick);
    _animController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.notoSerif(
                      fontSize: 28,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.onViewAll != null)
                  GestureDetector(
                    onTap: widget.onViewAll,
                    child: Text(
                      'View All',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF919191),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        SizedBox(
          height: 260,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _userScrolling = true;
              }
              if (notification is ScrollEndNotification) {
                _userScrolling = false;
              }
              return false;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: widget.products.length,
              itemBuilder: (context, index) =>
                  _buildCard(context, widget.products[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(BuildContext context, ProductModel product) {
    final appSetting = context.read<AppSettingCubit>();
    final priceData = _calcPrice(appSetting, product);

    return Semantics(
      label: product.name,
      button: true,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(
          context,
          RouteNames.productDetailsScreen,
          arguments: product.slug,
        ),
        child: Container(
          width: _cardWidth,
        margin: const EdgeInsets.only(right: _cardSpacing),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomImage(
                  path: RemoteUrls.imageUrl(product.thumbImage),
                  fit: BoxFit.cover,
                  width: _cardWidth,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE2E2E2),
                    ),
                  ),
                  const SizedBox(height: 4),
                  PriceCardWidget(
                    price: priceData['mainPrice']!,
                    offerPrice: priceData['offerPrice']!,
                    textSize: 14,
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

  Map<String, String> _calcPrice(
      AppSettingCubit appSetting, ProductModel product) {
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
