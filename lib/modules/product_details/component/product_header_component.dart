import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/favorite_button.dart';
import '../model/product_details_product_model.dart';

class ProductHeaderComponent extends StatefulWidget {
  const ProductHeaderComponent({
    super.key,
    required this.product,
    required this.images,
    required this.displayPrice,
    required this.actualPrice,
    this.selectedVariantId,
  });

  final ProductDetailsProductModel product;
  final List<String> images;
  final double displayPrice;
  final double actualPrice;
  final int? selectedVariantId;

  @override
  State<ProductHeaderComponent> createState() => _ProductHeaderComponentState();
}

class _ProductHeaderComponentState extends State<ProductHeaderComponent> {
  List<String> allImages = [];
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _buildSliderImages();
  }

  @override
  void didUpdateWidget(covariant ProductHeaderComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.images, oldWidget.images)) {
      _buildSliderImages();
      _currentIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    final PageController fullScreenCtrl = PageController(initialPage: initialIndex);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 0,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              PageView.builder(
                controller: fullScreenCtrl,
                itemCount: allImages.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: CustomImage(
                        path: RemoteUrls.imageUrl(allImages[index]),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              if (allImages.length > 1) ...[
                Positioned(
                  left: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 30),
                      onPressed: () {
                        if (fullScreenCtrl.hasClients && fullScreenCtrl.page != null && fullScreenCtrl.page! > 0) {
                          fullScreenCtrl.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 30),
                      onPressed: () {
                        if (fullScreenCtrl.hasClients && fullScreenCtrl.page != null && fullScreenCtrl.page! < allImages.length - 1) {
                          fullScreenCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _buildSliderImages() {
    allImages = widget.images
        .where((image) => image.trim().isNotEmpty)
        .toList(growable: true);
    if (allImages.isEmpty && widget.product.thumbImage.isNotEmpty) {
      allImages.add(widget.product.thumbImage);
    }
    if (!allImages.contains(widget.product.thumbImage) &&
        widget.product.thumbImage.isNotEmpty) {
      allImages.add(widget.product.thumbImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final displayPrice = widget.displayPrice;

    return Container(
      height: 520,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(color: Color(0xFF171717)),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: allImages.length,
            onPageChanged: (int index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullScreenImage(context, index),
                child: CustomImage(
                  path: RemoteUrls.imageUrl(allImages[index]),
                  fit: BoxFit.contain,
                ),
              );
            },
          ),
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.5, 1.0),
                  end: Alignment(0.5, 0.0),
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xE60A0A0A),
                    Color(0xB30A0A0A),
                    Color(0x000A0A0A),
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
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
                            if (_metadataLabel().isNotEmpty)
                              Text(
                                _metadataLabel().toUpperCase(),
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA3A3A3),
                                  letterSpacing: 3,
                                  height: 1.5,
                                  shadows: const [
                                    Shadow(
                                      color: Color(0xCC000000),
                                      blurRadius: 6,
                                    ),
                                  ],
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
                                shadows: const [
                                  Shadow(
                                    color: Color(0xCC000000),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.actualPrice > displayPrice)
                            Text(
                              Utils.formatPrice(widget.actualPrice, context),
                              textAlign: TextAlign.right,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA3A3A3),
                                decoration: TextDecoration.lineThrough,
                                height: 1.0,
                              ),
                            ),
                          if (widget.actualPrice > displayPrice)
                            const SizedBox(height: 2),
                          Text(
                            Utils.formatPrice(displayPrice, context),
                            textAlign: TextAlign.right,
                            style: GoogleFonts.notoSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.33,
                              shadows: const [
                                Shadow(
                                  color: Color(0xCC000000),
                                  blurRadius: 6,
                                ),
                              ],
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
            child: FavoriteButton(
              productId: widget.product.id,
              productSlug: widget.product.slug,
              variantId: widget.selectedVariantId,
            ),
          ),
        ],
      ),
    );
  }

  String _metadataLabel() {
    final labels = <String>[
      if (widget.product.gender.trim().isNotEmpty) widget.product.gender.trim(),
      if (widget.product.clothType.trim().isNotEmpty)
        widget.product.clothType.trim(),
      if (widget.product.category != null) widget.product.category!.name,
    ];
    return labels.join(' / ');
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
