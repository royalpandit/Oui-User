import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DetailsPageLoading extends StatelessWidget {
  const DetailsPageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image skeleton (full width, no rounded corners)
            _skeleton(height: 520, width: double.infinity),
            const SizedBox(height: 48),
            // Tab bar skeleton
            Row(
              children: List.generate(
                3,
                (_) => Expanded(
                  child: Container(
                    height: 48,
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom:
                            BorderSide(color: Color(0xFF262626), width: 1),
                      ),
                    ),
                    child: Center(
                      child: _skeleton(height: 10, width: 80),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Description skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeleton(height: 14, width: 200),
                  const SizedBox(height: 16),
                  _skeleton(height: 10, width: double.infinity),
                  const SizedBox(height: 10),
                  _skeleton(height: 10, width: double.infinity),
                  const SizedBox(height: 10),
                  _skeleton(height: 10, width: 260),
                  const SizedBox(height: 10),
                  _skeleton(height: 10, width: double.infinity),
                  const SizedBox(height: 10),
                  _skeleton(height: 10, width: 180),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Related products skeleton
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeleton(height: 10, width: 120),
                  const SizedBox(height: 8),
                  _skeleton(height: 20, width: 180),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                separatorBuilder: (_, __) => const SizedBox(width: 2),
                itemCount: 3,
                itemBuilder: (_, __) => SizedBox(
                  width: 165,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeleton(height: 165, width: 165),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _skeleton(height: 10, width: 120),
                            const SizedBox(height: 6),
                            _skeleton(height: 12, width: 70),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeleton({required double height, required double width}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1B1B1B),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        height: height,
        width: width,
        color: const Color(0xFF1B1B1B),
      ),
    );
  }
}
