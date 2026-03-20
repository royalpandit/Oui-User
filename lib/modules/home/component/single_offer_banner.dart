import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '../../../core/remote_urls.dart';
import '../../../widgets/custom_image.dart';
import '../model/slider_model.dart';

class SingleOfferBanner extends StatelessWidget {
  const SingleOfferBanner({
    super.key,
    required this.slider,
    required this.onTap,
  });
  final SliderModel slider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomImage(
          path: RemoteUrls.imageUrl(slider.image),
          fit: BoxFit.cover,
        ),
        // Dark gradient overlay for text readability
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF131313).withValues(alpha: 0.85),
                const Color(0xFF131313).withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Positioned(
          left: 24,
          top: 24,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (slider.titleOne.isNotEmpty)
                Text(
                  slider.titleOne.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF919191),
                    letterSpacing: 1.5,
                  ),
                ),
              const SizedBox(height: 6),
              SizedBox(
                width: 180,
                child: Text(
                  slider.titleTwo,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    Language.shopNow.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1A1C1C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}