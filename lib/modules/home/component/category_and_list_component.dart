import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../model/product_model.dart';
import 'home_horizontal_list_product_card.dart';
import 'section_header.dart';

class CategoryAndListComponent extends StatelessWidget {
  const CategoryAndListComponent({
    super.key,
    required this.productList,
    required this.category,
    this.bgColor,
    this.onTap,
  });

  final List<ProductModel> productList;
  final String category;
  final Color? bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // We only hide the section if it's explicitly null/empty in a real production state. 
    // Otherwise, we show a skeleton to prevent layout shifts.
    final bool isLoading = productList.isEmpty;

    // Enhanced Title Case: Ensures "hot  shot category" -> "Hot Shot Category"
    final String formattedCategory = category
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' 
            : '')
        .join(' ');

    return SliverToBoxAdapter(
      child: Container(
        color: bgColor ?? Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header with standardized padding
            SectionHeader(
              headerText: formattedCategory,
              onTap: onTap,
            ),
            
            const SizedBox(height: 16),

            // 2. Horizontal List Container
            SizedBox(
              height: 160, // Fixed height to prevent pixel overflow
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: isLoading ? 3 : productList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  if (isLoading) {
                    return const _CardSkeleton();
                  }
                  return HomeHorizontalListProductCard(
                    productModel: productList[index],
                    height: 150,
                    width: 280,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Professional Shimmer Skeleton for the Horizontal Cards
class _CardSkeleton extends StatelessWidget {
  const _CardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        width: 280,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}