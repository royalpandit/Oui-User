import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../utils/utils.dart';

class PriceCardWidget extends StatelessWidget {
  const PriceCardWidget({
    super.key,
    required this.price,
    required this.offerPrice,
    this.textSize = 14,
    this.priceColor = const Color(0xFFE2E2E2),
  });
  final String price;
  final double textSize;
  final String offerPrice;
  final Color priceColor;

  @override
  Widget build(BuildContext context) {
    if (offerPrice == "0.0") {
      return _buildPrice(Utils.formatPrice(price, context), context);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AutoSizeText(
          Utils.formatPrice(price, context),
          textAlign: TextAlign.left,
          maxFontSize: textSize - 2,
          minFontSize: textSize - 4,
          style: TextStyle(
            decoration: TextDecoration.lineThrough,
            decorationColor: const Color(0xFF919191),
            color: const Color(0xFF919191),
            height: 1.5,
            fontSize: textSize,
          ),
          maxLines: 1,
        ),
        const SizedBox(width: 8),
        _buildPrice(Utils.formatPrice(offerPrice, context), context),
      ],
    );
  }

  Widget _buildPrice(String price, BuildContext context) {
    return Text(
      price,
      style: GoogleFonts.manrope(
        color: priceColor,
        height: 1.43,
        fontSize: textSize,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}