import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/widgets/custom_image.dart';

import '/core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../model/home_seller_model.dart';

class SingleCircularSeller extends StatelessWidget {
  const SingleCircularSeller({
    super.key,
    required this.seller,
  });

  final HomeSellerModel seller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteNames.bestSellerScreen,
          arguments: {
            'name': seller.shopName,
            'keyword': seller.slug,
          },
        );
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF474747), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF474747), width: 0.5),
              ),
              child: ClipOval(
                child: CustomImage(
                  height: 32,
                  width: 32,
                  path: RemoteUrls.imageUrl(seller.logo),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              seller.shopName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFC7C6C6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}