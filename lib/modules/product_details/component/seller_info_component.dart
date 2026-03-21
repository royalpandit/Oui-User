import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../model/product_details_model.dart';
import 'related_single_product_card.dart';

class SellerInfo extends StatelessWidget {
  const SellerInfo({super.key, this.productDetailsModel});
  final ProductDetailsModel? productDetailsModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (productDetailsModel!.sellerProfile != null) ...[
            _buildSellerProfile(),
            const SizedBox(height: 32),
            _buildProvenance(),
            const SizedBox(height: 32),
            _buildStatsGrid(),
            const SizedBox(height: 32),
          ],
          if ((productDetailsModel!.tags ?? '').isNotEmpty) ...[
            _buildTags(),
            const SizedBox(height: 32),
          ],
          if (productDetailsModel!.thisSellerProducts.isNotEmpty)
            _buildSellerProducts(),
        ],
      ),
    );
  }

  Widget _buildSellerProfile() {
    final seller = productDetailsModel!.sellerProfile!;
    return Center(
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF262626), width: 2),
            ),
            child: CircleAvatar(
              radius: 62,
              backgroundImage:
                  NetworkImage(RemoteUrls.imageUrl(seller.image)),
              backgroundColor: const Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            seller.name,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.07,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'CURATED BY ${seller.name.toUpperCase()}',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF737373),
              letterSpacing: 3.6,
              height: 1.33,
            ),
          ),
          if (seller.address.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFF2A2A2A),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.language,
                      size: 14, color: Color(0xFF919191)),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      seller.address.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF919191),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProvenance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFF262626), width: 1),
          bottom: BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      child: Column(
        children: [
          Text(
            'PROVENANCE',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF737373),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '"Where tradition meets\ncontemporary design."',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            _buildStatCell(
              productDetailsModel!.sellerTotalProducts.toString(),
              'TOTAL\nPRODUCTS',
            ),
            const SizedBox(width: 2),
            _buildStatCell(
              productDetailsModel!.product.category?.name.toUpperCase() ?? '',
              'PRIMARY\nCATEGORY',
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            _buildStatCell(
              productDetailsModel!.sellerReviewQty != null
                  ? productDetailsModel!.sellerReviewQty!.toStringAsFixed(1)
                  : '—',
              'SELLER\nRATING',
            ),
            const SizedBox(width: 2),
            _buildStatCell(
              productDetailsModel!.sellerTotalReview.toString(),
              'TOTAL\nREVIEWS',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCell(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        color: const Color(0xFF1B1B1B),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.notoSerif(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.33,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
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
      ),
    );
  }

  Widget _buildTags() {
    final tags = (productDetailsModel!.tags ?? '')
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SPECIALIZATIONS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF737373),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tags
              .map((tag) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    color: const Color(0xFF1B1B1B),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco_outlined,
                            size: 14, color: Color(0xFF919191)),
                        const SizedBox(width: 8),
                        Text(
                          tag.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFE2E2E2),
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSellerProducts() {
    final products = productDetailsModel!.thisSellerProducts;
    final itemCount = products.length < 4 ? products.length : 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELLER COLLECTION',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF737373),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final rows = (itemCount / 2).ceil();
            final gridHeight = rows * 290.0 + (rows - 1) * 2.0;
            return SizedBox(
              height: gridHeight,
              child: GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  mainAxisExtent: 290.0,
                ),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  return RelatedSingleProductCard(
                    productModel: products[index],
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
