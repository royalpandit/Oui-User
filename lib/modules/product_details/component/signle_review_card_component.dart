import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/utils.dart';
import '../model/details_product_reviews_model.dart';

class SingleReviewCardComponent extends StatelessWidget {
  const SingleReviewCardComponent(
    this.reviewModel, {
    super.key,
  });

  final DetailsProductReviewModel reviewModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stars + date
          Row(
            children: [
              Opacity(
                opacity: 0.6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    return Icon(
                      index <
                              Utils.toDouble(reviewModel.rating.toString())
                                  .round()
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: Colors.white,
                      size: 14,
                    );
                  }),
                ),
              ),
              const Spacer(),
              Text(
                Utils.timeAgo(reviewModel.createdAt),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: const Color(0xFF737373),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review text
          if (reviewModel.review.isNotEmpty)
            Text(
              reviewModel.review,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFC7C6C6),
                height: 1.57,
              ),
            ),
          const SizedBox(height: 12),
          // Name — VERIFIED
          Text(
            '${reviewModel.user.name.toUpperCase()} — VERIFIED',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF919191),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
