import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoader extends StatelessWidget {
  const ShimmerLoader({super.key, this.height, this.width});

  const ShimmerLoader.rect({super.key, required this.height, required this.width});

  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
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
