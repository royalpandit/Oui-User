import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/utils.dart';
import '../model/details_product_reviews_model.dart';
import 'signle_review_card_component.dart';

class ReviewListComponent extends StatelessWidget {
  const ReviewListComponent(
    this.productReviews, {
    super.key,
  });

  final List<DetailsProductReviewModel> productReviews;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildRatingHeader(),
          const SizedBox(height: 64),
          ...productReviews
              .take(3)
              .map((e) => SingleReviewCardComponent(e)),
          if (productReviews.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 48, vertical: 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                            color: Color(0xFF777777), width: 1),
                      ),
                    ),
                    child: Text(
                      'LOAD MORE REVIEWS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE2E2E2),
                        letterSpacing: 3,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRatingHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x33C6C6C6), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Utils.getRating(productReviews).toStringAsFixed(1),
                    style: GoogleFonts.notoSerif(
                      fontSize: 48,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: index <
                                  Utils.getRating(productReviews).round()
                              ? Colors.amber
                              : const Color(0xFF474747),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'BASED ON ${productReviews.length} VERIFIED ACQUISITIONS',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF919191),
                      letterSpacing: 1,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'WRITE A REVIEW',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    letterSpacing: 1,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
