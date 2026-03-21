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
  final double height = 160;
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
            viewportFraction: 0.85,
            initialPage: 0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
            autoPlayCurve: Curves.easeInOutCubic,
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
              child: HotDealBanner(
                banner: banner,
                alignRight: index % 2 != 0,
              ),
            );
          },
        ),
        const SizedBox(height: 14),
        _buildPillIndicator(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPillIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        bool isActive = _currentIndex == entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 4,
          width: isActive ? 24 : 4,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: isActive ? Colors.white : const Color(0xFF474747),
          ),
        );
      }).toList(),
    );
  }
}