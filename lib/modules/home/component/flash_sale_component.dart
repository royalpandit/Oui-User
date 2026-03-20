import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router_name.dart';
import '../../../utils/language_string.dart';
import '../../../widgets/capitalized_word.dart';
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

    int endTime = DateTime.parse(flashSale.endTime).millisecondsSinceEpoch;

    return BlocBuilder<FlashCubit, FlashState>(
      builder: (context, state) {
        if (state is FlashInitial) {
          cubit.getFalshSale();
          return const SizedBox.shrink();
        }
        if (state is FlashSaleLoaded && state.flashModel.products.isNotEmpty) {
          return _buildFlashContent(context, state.flashModel.products, endTime);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFlashContent(BuildContext context, List<ProductModel> products, int endTime) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF474747), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "FLASH SALE",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
              CountdownTimer(
                endTime: endTime,
                widgetBuilder: (_, time) {
                  if (time == null) {
                    return Text(
                      "ENDED",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: const Color(0xFF919191),
                      ),
                    );
                  }
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
          const SizedBox(height: 16),
          SizedBox(
            height: 280,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
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
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, RouteNames.flashScreen),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF474747), width: 1),
                ),
                child: Text(
                  Language.seeAll.capitalizeByWord().toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFFC7C6C6),
                    letterSpacing: 1.0,
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
              color: const Color(0xFF1A1C1C),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          unit,
          style: GoogleFonts.inter(
            fontSize: 9,
            color: const Color(0xFF919191),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerDivider() => Padding(
    padding: const EdgeInsets.only(bottom: 12, left: 3, right: 3),
    child: Text(
      ":",
      style: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: const Color(0xFF919191),
      ),
    ),
  );
}