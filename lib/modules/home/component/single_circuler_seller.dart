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
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A), width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Banner area
            SizedBox(
              height: 70,
              width: double.infinity,
              child: seller.bannerImage.isNotEmpty
                  ? CustomImage(
                      path: RemoteUrls.imageUrl(seller.bannerImage),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2A2A2A),
                            Color(0xFF1B1B1B),
                          ],
                        ),
                      ),
                    ),
            ),
            // Logo overlapping banner bottom
            Transform.translate(
              offset: const Offset(0, -22),
              child: Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A2A),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF1B1B1B), width: 2),
                ),
                child: ClipOval(
                  child: CustomImage(
                    height: 28,
                    width: 28,
                    path: RemoteUrls.imageUrl(seller.logo),
                  ),
                ),
              ),
            ),
            // Name + visit label
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: Column(
                  children: [
                    Text(
                      seller.shopName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE2E2E2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'VISIT STORE',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF919191),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}