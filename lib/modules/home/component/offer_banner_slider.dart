import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../core/router_name.dart';
import '../model/slider_model.dart';
import 'single_offer_banner.dart';

class OfferBannerSlider extends StatefulWidget {
  const OfferBannerSlider({
    super.key,
    required this.sliders,
  });

  final List<SliderModel> sliders;

  @override
  State<OfferBannerSlider> createState() => _OfferBannerSliderState();
}

class _OfferBannerSliderState extends State<OfferBannerSlider> {
  final double height = 200;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.sliders.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        CarouselSlider(
          items: widget.sliders.map((slider) {
            return Builder(
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleOfferBanner(
                      slider: slider,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          RouteNames.productDetailsScreen,
                          arguments: slider.productSlug,
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: height,
            viewportFraction: 1.0,
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
            scrollDirection: Axis.horizontal,
          ),
        ),
        const SizedBox(height: 14),
        _buildDotIndicator(),
      ],
    );
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.sliders.asMap().entries.map((entry) {
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