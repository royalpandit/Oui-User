import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage:
                NetworkImage(RemoteUrls.imageUrl(reviewModel.user.image ?? '')),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(reviewModel.user.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black)),
                    ),
                    Text(
                      Utils.timeAgo(reviewModel.createdAt),
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                RatingBar.builder(
                  initialRating: Utils.toDouble(reviewModel.rating.toString()),
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  ignoreGestures: true,
                  itemCount: 5,
                  itemSize: 14,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {},
                ),
                if (reviewModel.review.isNotEmpty) ...[                
                  const SizedBox(height: 6),
                  Text(
                    reviewModel.review,
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
