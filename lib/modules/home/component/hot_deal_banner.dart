import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../model/banner_model.dart';

class HotDealBanner extends StatelessWidget {
  const HotDealBanner({
    super.key,
    required this.banner,
    this.alignRight = false,
  });

  final BannerModel banner;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (banner.slug.isNotEmpty) {
          Navigator.pushNamed(
            context,
            RouteNames.singleCategoryProductScreen,
            arguments: {
              'keyword': banner.slug,
              'app_bar': banner.titleOne.isNotEmpty ? banner.titleOne : banner.slug,
            },
          );
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: RemoteUrls.rootUrl + banner.image,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: const Color(0xFFF5F5F5),
            ),
            errorWidget: (context, url, error) => Container(
              color: const Color(0xFFF5F5F5),
              child: const Icon(Icons.image_not_supported, color: Colors.grey),
            ),
          ),
          // Gradient overlay for text readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: alignRight ? Alignment.centerRight : Alignment.centerLeft,
                  end: alignRight ? Alignment.centerLeft : Alignment.centerRight,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Text content
          Positioned(
            left: alignRight ? null : 20.0,
            right: alignRight ? 20.0 : null,
            top: 0,
            bottom: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (banner.badge.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      banner.badge.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                if (banner.titleOne.isNotEmpty)
                  Text(
                    banner.titleOne,
                    textAlign: alignRight ? TextAlign.right : TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                if (banner.titleTwo.isNotEmpty)
                  Text(
                    banner.titleTwo,
                    textAlign: alignRight ? TextAlign.right : TextAlign.left,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}