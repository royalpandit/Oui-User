import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildRatingHeader(),
          const SizedBox(height: 30),
          ...productReviews.take(3).map((e) => SingleReviewCardComponent(e)),
          if (productReviews.length > 3)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: InkWell(
                onTap: () {
                  // Navigator.pushNamed(context, RouteNames.reviewListScreen,
                  //     arguments: productReviews);
                },
                child: const Text(
                  "See all reviews",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildRatingHeader() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            Utils.getRating(productReviews).toStringAsFixed(1),
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RatingBar.builder(
                initialRating: Utils.getRating(productReviews),
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                ignoreGestures: true,
                itemCount: 5,
                itemSize: 18,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {},
              ),
              const SizedBox(height: 4),
              Text(
                '${productReviews.length} Review${productReviews.length != 1 ? 's' : ''}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              )
            ],
          ),
        ],
      ),
    );
  }
}
