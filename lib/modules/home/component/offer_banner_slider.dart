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
  final double height = 180;
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
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      // Professional subtle border for a premium feel
                      border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SingleOfferBanner(
                        slider: slider,
                        // Fix: Passing the required onTap parameter
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RouteNames.productDetailsScreen,
                            arguments: slider.productSlug,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
          options: CarouselOptions(
            height: height,
            viewportFraction: 1.0, // Ensures proper full-width container scaling
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
        const SizedBox(height: 12),
        // Modern Expanding Pill Indicator
        buildDotIndicator(),
      ],
    );
  }

  Widget buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.sliders.asMap().entries.map((entry) {
        bool isActive = _currentIndex == entry.key;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          width: isActive ? 20 : 6, // Expanding pill effect
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