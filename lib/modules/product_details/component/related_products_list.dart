import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/product_details_product_model.dart';
import 'related_single_product_card.dart';

class RelatedProductsList extends StatelessWidget {
  const RelatedProductsList(
    this.relatedProducts, {
    super.key,
  });
  final List<ProductDetailsProductModel> relatedProducts;

  @override
  Widget build(BuildContext context) {
    if (relatedProducts.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMPLETE THE LOOK',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF737373),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Curated Essentials',
                style: GoogleFonts.notoSerif(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.33,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 280,
          child: ListView.separated(
            separatorBuilder: (_, __) => const SizedBox(width: 2),
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) => RelatedSingleProductCard(
              productModel: relatedProducts[index],
              width: 165,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
