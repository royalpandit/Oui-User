import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/router_name.dart';
import '../../../utils/language_string.dart';
import '../../category/component/product_card.dart';
import '../../flash/controller/cubit/flash_cubit.dart';
import '../model/flash_sale_model.dart';
import '../model/product_model.dart';

class FlashSaleComponent extends StatelessWidget {
  const FlashSaleComponent({
    super.key,
    required this.flashSale,
  });

  final FlashSaleModel flashSale;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<FlashCubit>();
    
    // Safety check: trigger fetch if not already loaded
    if (cubit.flashModel == null) {
      cubit.getFalshSale();
    }

    int endTime = DateTime.parse(flashSale.endTime).millisecondsSinceEpoch;

    return BlocBuilder<FlashCubit, FlashState>(
      builder: (context, state) {
        // If data is available, show the component; else show skeleton
        if (state is FlashSaleLoaded && state.flashModel.products.isNotEmpty) {
          return _buildFlashContent(context, state.flashModel.products, endTime);
        } else if (state is FlashSaleLoading) {
          return const _FlashSaleSkeleton();
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFlashContent(BuildContext context, List<ProductModel> products, int endTime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9), // Premium light off-white
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Flash Sale",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              CountdownTimer(
                endTime: endTime,
                widgetBuilder: (_, time) {
                  if (time == null) return const Text("Sale Ended");
                  return Row(
                    children: [
                      _buildTimerUnit(time.days ?? 0, 'D'),
                      _buildTimerDivider(),
                      _buildTimerUnit(time.hours ?? 0, 'H'),
                      _buildTimerDivider(),
                      _buildTimerUnit(time.min ?? 0, 'M'),
                      _buildTimerDivider(),
                      _buildTimerUnit(time.sec ?? 0, 'S'),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 290,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: products.length > 6 ? 6 : products.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return ProductCard(
                  width: 155, 
                  productModel: products[index],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.flashScreen),
              child: Text(
                Language.seeAll.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(int value, String unit) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.robotoMono(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  Widget _buildTimerDivider() => const Padding(
    padding: EdgeInsets.only(bottom: 12, left: 4, right: 4),
    child: Text(":", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  );
}

// Minimalist Shimmer Skeleton
class _FlashSaleSkeleton extends StatelessWidget {
  const _FlashSaleSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}