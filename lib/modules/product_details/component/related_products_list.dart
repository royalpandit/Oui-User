import 'package:flutter/material.dart';
import 'package:shop_us/utils/language_string.dart';
import 'package:shop_us/widgets/capitalized_word.dart';

import '../../home/component/section_header.dart';
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
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: SectionHeader(
            headerText: Language.relatedProduct.capitalizeByWord(),
            isSeeAll: false,
          ),
        ),
        SizedBox(
          height: 290.0,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: relatedProducts.length,
            itemBuilder: (context, index) => RelatedSingleProductCard(
                productModel: relatedProducts[index], width: 165),
          ),
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}
