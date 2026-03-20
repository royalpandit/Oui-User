import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../utils/k_images.dart';
import '../../../widgets/custom_image.dart';
import '../../category/component/product_card.dart';
import '../model/product_model.dart';

class NewArrivalComponent extends StatelessWidget {
  const NewArrivalComponent({
    super.key,
    required this.productList,
    required this.sectionTitle,
  });

  final List<ProductModel> productList;
  final String sectionTitle;

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
              padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedTitle,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15.0,
                      color: Colors.black,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 20,
              mainAxisExtent: 280.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                // Return your main ProductCard here
                return ProductCard(productModel: productList[index]);
              },
              childCount: productList.length > 8 ? 8 : productList.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}