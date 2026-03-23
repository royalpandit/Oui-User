import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../category/component/product_card.dart';
import '../model/product_model.dart';
import 'section_header.dart';

class NewArrivalComponent extends StatelessWidget {
  const NewArrivalComponent({
    super.key,
    required this.productList,
    required this.sectionTitle,
    this.onViewAll,
  });

  final List<ProductModel> productList;
  final String sectionTitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    String formattedTitle = sectionTitle.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 16),
              child: SectionHeader(
                headerText: formattedTitle,
                onTap: onViewAll,
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 14,
              mainAxisExtent: 270,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return ProductCard(productModel: productList[index]);
              },
              childCount: productList.length > 6 ? 6 : productList.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}