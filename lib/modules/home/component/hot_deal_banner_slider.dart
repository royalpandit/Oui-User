import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../model/banner_model.dart';
import 'hot_deal_banner.dart';

class CombineBannerSlider extends StatefulWidget {
  const CombineBannerSlider({
    super.key,
    required this.banners,
  });

  final List<BannerModel> banners;

  @override
  State<CombineBannerSlider> createState() => _CombineBannerSliderState();
}

class _CombineBannerSliderState extends State<CombineBannerSlider> {
  final double height = 160; // Slightly increased for a more modern aspect ratio
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 16),
        CarouselSlider.builder(
          itemCount: widget.banners.length,
          options: CarouselOptions(
            height: height,
            // 0.85 allows a professional "peek" at adjacent banners
            viewportFraction: 0.85,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInOutCubic,
            // Adds a subtle focus effect to the center banner
            enlargeCenterPage: true, 
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
          itemBuilder: (context, index, realIndex) {
            final banner = widget.banners[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: HotDealBanner(
                  banner: banner,
                  // Logic: align right every second banner for visual rhythm
                  alignRight: index % 2 != 0, 
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        // Custom Expanding Pill Indicator
        _buildExpandingPillIndicator(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildExpandingPillIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        bool isActive = _currentIndex == entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          // Pill stretches when active
          width: isActive ? 24 : 6, 
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive ? Colors.black : Colors.black.withOpacity(0.1),
          ),
        );
      }).toList(),
    );
  }
}