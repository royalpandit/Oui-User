import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../../core/remote_urls.dart';
import '../model/product_details_model.dart';
import 'related_single_product_card.dart';

class SellerInfo extends StatelessWidget {
  const SellerInfo({super.key, this.productDetailsModel});
  final ProductDetailsModel? productDetailsModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productDetailsModel!.sellerProfile != null)
            SellerProfile(productDetailsModel: productDetailsModel!),

          SellerProducts(
            title: Language.products.capitalizeByWord(),
            value: productDetailsModel!.sellerTotalProducts.toString(),
          ),
          SellerProducts(
            title: Language.category.capitalizeByWord(),
            value: productDetailsModel!.product.category!.name,
          ),
          SellerProducts(
            title: Language.tags.capitalizeByWord(),
            value: productDetailsModel!.tags,
          ),

          productDetailsModel!.thisSellerProducts.isNotEmpty
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    final itemCount = productDetailsModel!.thisSellerProducts.length < 4
                        ? productDetailsModel!.thisSellerProducts.length
                        : 4;
                    final rows = (itemCount / 2).ceil();
                    final gridHeight = rows * 290.0 + (rows - 1) * 10.0;
                    return SizedBox(
                      height: gridHeight,
                      child: GridView.builder(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 290.0,
                        ),
                        itemCount: itemCount,
                        itemBuilder: (context, index) {
                          return RelatedSingleProductCard(
                              productModel:
                                  productDetailsModel!.thisSellerProducts[index]);
                        },
                      ),
                    );
                  },
                )
              : const SizedBox(),
          // SliverGrid(
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 2,
          //     crossAxisSpacing: 10,
          //     mainAxisSpacing: 10,
          //     mainAxisExtent: 230,
          //   ),
          //   delegate: SliverChildBuilderDelegate(
          //         (BuildContext context, int index) {
          //       return RelatedSingleProductCard(productModel:  productDetailsModel!.thisSellerProducts[index]);
          //     },
          //     childCount: productDetailsModel!.thisSellerProducts.length < 4 ? productDetailsModel!.thisSellerProducts.length : 4,
          //   ),
          // ),
        ],
      ),
    );
  }
}

class SellerProfile extends StatelessWidget {
  const SellerProfile({
    super.key,
    required this.productDetailsModel,
  });
  final ProductDetailsModel? productDetailsModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14.0),
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            height: 60.0,
            width: 60.0,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(RemoteUrls.imageUrl(
                  productDetailsModel!.sellerProfile!.image)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productDetailsModel!.sellerProfile!.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  productDetailsModel!.sellerProfile!.address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    RatingBar.builder(
                      initialRating:
                          productDetailsModel!.sellerReviewQty!.toDouble(),
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      ignoreGestures: true,
                      itemCount: 5,
                      itemSize: 14,
                      itemPadding:
                          const EdgeInsets.symmetric(horizontal: 1.0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(${productDetailsModel!.sellerTotalReview})',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SellerProducts extends StatelessWidget {
  const SellerProducts({
    super.key,
    this.title,
    this.value,
  });
  final String? title;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          text: "$title: ",
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
          children: [
            TextSpan(
              text: "$value",
              style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
