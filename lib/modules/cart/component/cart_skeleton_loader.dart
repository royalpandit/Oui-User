import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CartSkeletonLoader extends StatelessWidget {
  const CartSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App bar skeleton
          Container(
            padding: EdgeInsets.fromLTRB(24, topPadding + 12, 24, 12),
            decoration: const BoxDecoration(
              color: Color(0xFF131313),
              border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF), width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(20, 20),
                _shimmerBox(140, 16),
                const SizedBox(width: 20),
              ],
            ),
          ),

          // Items count
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: _shimmerBox(160, 14),
          ),

          // Cart item 1
          _buildCartItemSkeleton(),

          // Cart item 2
          _buildCartItemSkeleton(),
        ],
      ),
    );
  }

  Widget _buildCartItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          _shimmerBox(double.infinity, 360),
          const SizedBox(height: 32),
          // Name
          _shimmerBox(220, 24),
          const SizedBox(height: 12),
          // Variant line
          _shimmerBox(160, 14),
          const SizedBox(height: 8),
          // Quantity line
          _shimmerBox(100, 14),
          const SizedBox(height: 24),
          // Action buttons
          Row(
            children: [
              _shimmerBox(40, 14),
              const SizedBox(width: 24),
              _shimmerBox(60, 14),
            ],
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _shimmerBox(double width, double height) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1B1B1B),
      highlightColor: const Color(0xFF2A2A2A),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFF1B1B1B),
      ),
    );
  }
}
