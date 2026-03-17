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
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
              child: Text(sectionTitle,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.0,
                    color: Colors.black,
                  ))),
          const SliverPadding(padding: EdgeInsets.symmetric(vertical: 10.0)),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 304.0,
            ),
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) =>
                  ProductCard(productModel: productList[index]),
              childCount: productList.length > 8 ? 8 : productList.length,
            ),
          ),
        ],
      ),
    );
  }
}

class NewArrivalRow extends StatelessWidget {
  NewArrivalRow({super.key});
  final List<String> list = <String>[
    'New Arrival',
    'Best Selling',
    'Discount Products',
    'Height Price',
    'Low Price',
    'Free Delivery'
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'New Arrival',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        PopupMenuButton<String>(
          position: PopupMenuPosition.under,
          constraints: const BoxConstraints(maxWidth: 180.0),
          icon: const CustomImage(path: KImages.newArrivalFilter),
          padding: EdgeInsets.zero,
          itemBuilder: (context) {
            return list
                .map<PopupMenuItem<String>>(
                  (item) => PopupMenuItem(
                    value: item,
                    height: 36.0,
                    child: Text(
                      item,
                      style: GoogleFonts.inter(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        height: 0.6,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
                .toList();
          },
        ),
      ],
    );
  }
}
