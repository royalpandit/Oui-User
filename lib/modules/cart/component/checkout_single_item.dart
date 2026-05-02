import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../model/cart_product_model.dart';

class CheckoutSingleItem extends StatelessWidget {
  const CheckoutSingleItem({super.key, required this.product});

  final CartProductModel product;

  @override
  Widget build(BuildContext context) {
    final selectedColors = _resolvedColors();
    final selectedSizes = product.selectedSizes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        color: Colors.white,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, RouteNames.productDetailsScreen,
                arguments: product.product.slug),
            child: Container(
              margin: const EdgeInsets.all(6.0).copyWith(right: 4.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F6F6),
                borderRadius: BorderRadius.circular(6.0),
              ),
              height: 110.0,
              width: 110.0,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: CustomImage(
                  path: RemoteUrls.imageUrl(product.product.displayImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      if (_attributeLabel().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            _attributeLabel().toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      Utils.formatPrice(
                          Utils.cartProductPrice(context, product), context),
                      style: GoogleFonts.inter(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        'x ${product.qty}',
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                if (selectedColors.isNotEmpty || selectedSizes.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...selectedSizes.map(
                          (size) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                            ),
                            child: Text(
                              'SIZE: ${size.toUpperCase()}',
                              style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade700),
                            ),
                          ),
                        ),
                        ...selectedColors.map(_buildColorChip),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _resolvedColors() {
    final colors = <String>{
      ...product.selectedColors.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };

    for (final variant in product.variants) {
      final item = variant.varientItem;
      if (item == null) continue;
      final isColorType =
          item.productVariantName.toLowerCase().contains('color');
      if (isColorType && item.name.trim().isNotEmpty) {
        colors.add(item.name.trim());
      }
    }

    return colors.toList();
  }

  Widget _buildColorChip(String colorName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Utils.parseColorLabel(colorName, fallback: Colors.grey),
              border: Border.all(color: Colors.grey.shade500, width: 0.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'COLOR: ${colorName.toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  String _attributeLabel() {
    final labels = <String>[
      if (product.product.gender.trim().isNotEmpty)
        product.product.gender.trim(),
      if (product.product.clothType.trim().isNotEmpty)
        product.product.clothType.trim(),
    ];
    return labels.join(' / ');
  }
}
