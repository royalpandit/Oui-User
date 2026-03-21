import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/favorite_button.dart';
import '../../home/model/product_model.dart';
import '../model/product_details_product_model.dart';

class ProductHeaderComponent extends StatefulWidget {
  const ProductHeaderComponent({
    super.key,
    required this.product,
    required this.gallery,
  });

  final ProductDetailsProductModel product;
  final List<GalleryModel?> gallery;

  @override
  State<ProductHeaderComponent> createState() => _ProductHeaderComponentState();
}

class _ProductHeaderComponentState extends State<ProductHeaderComponent> {
  late List<String> allImages = [];
  int _currentIndex = 0;

  @override
  void initState() {
    _buildSliderImages();
    super.initState();
  }

  void _buildSliderImages() {
    allImages.add(widget.product.thumbImage);
    for (final img in widget.gallery) {
      if (img != null && img.image.isNotEmpty) {
        allImages.add(img.image);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final displayPrice = widget.product.offerPrice > 0
        ? widget.product.offerPrice
        : widget.product.price;

    return Container(
      height: 520,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFF171717)),
      child: Stack(
        children: [
          PageView.builder(
            itemCount: allImages.length,
            onPageChanged: (int index) =>
                setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return CustomImage(
                path: RemoteUrls.imageUrl(allImages[index]),
                fit: BoxFit.contain,
              );
            },
          ),
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.5, 1.0),
                  end: Alignment(0.5, 0.0),
                  colors: [Color(0xFF0A0A0A), Color(0x000A0A0A)],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.product.category != null)
                              Text(
                                widget.product.category!.name.toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA3A3A3),
                                  letterSpacing: 3,
                                  height: 1.5,
                                ),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              widget.product.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSerif(
                                fontSize: 36,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Utils.formatPrice(displayPrice, context),
                            textAlign: TextAlign.right,
                            style: GoogleFonts.notoSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.33,
                            ),
                          ),
                          Text(
                            'INCL. ALL\nTAXES',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF737373),
                              letterSpacing: 1,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDotIndicators(),
                ],
              ),
            ),
          ),
          // Wishlist button on image
          Positioned(
            right: 16,
            top: topPadding + 72,
            child: FavoriteButton(productId: widget.product.id),
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        allImages.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 6,
          width: _currentIndex == index ? 24 : 6,
          decoration: BoxDecoration(
            color: _currentIndex == index
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
