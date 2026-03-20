import 'package:flutter/material.dart';
import '../../category/component/product_card.dart';
import '../model/product_model.dart';
import 'section_header.dart';

class HorizontalProductComponent extends StatelessWidget {
  const HorizontalProductComponent({
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
    if (productList.isEmpty) return const SliverToBoxAdapter();

    String formattedCategory = category.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return SliverToBoxAdapter(
      child: Container(
        color: bgColor ?? Colors.transparent,
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              headerText: formattedCategory,
              onTap: onTap,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 280,
              child: ListView.separated(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: productList.length > 8 ? 8 : productList.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ProductCard(
                    productModel: productList[index],
                    width: 160,
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