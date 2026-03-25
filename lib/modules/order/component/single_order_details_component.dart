import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../model/product_order_model.dart';

class SingleOrderDetailsComponent extends StatelessWidget {
  const SingleOrderDetailsComponent({
    super.key,
    required this.orderItem,
    this.isOrdered = false,
  });

  final bool isOrdered;
  final OrderedProductModel orderItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0x33444444), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          Container(
            width: 72,
            height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFF262626)),
            child: orderItem.thumbImage.isNotEmpty
                ? CustomImage(
                    path: RemoteUrls.imageUrl(orderItem.thumbImage),
                    height: 96,
                    width: 72,
                    fit: BoxFit.cover,
                  )
                : Icon(Icons.shopping_bag_outlined,
                    size: 24, color: Colors.white.withValues(alpha: 0.15)),
          ),
          const SizedBox(width: 14),
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderItem.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE2E2E2),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                // Color & Size chips - hidden
                // if (orderItem.color.isNotEmpty || orderItem.size.isNotEmpty)
                //   Padding(
                //     padding: const EdgeInsets.only(bottom: 6),
                //     child: Wrap(
                //       spacing: 6,
                //       runSpacing: 4,
                //       children: [
                //         if (orderItem.size.isNotEmpty)
                //           _infoChip('SIZE: ${orderItem.size.toUpperCase()}'),
                //         if (orderItem.color.isNotEmpty)
                //           _infoChip('COLOR: ${orderItem.color.toUpperCase()}'),
                //       ],
                //     ),
                //   ),
                // Qty & Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Qty: ${orderItem.qty}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF777777),
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      Utils.formatPrice(orderItem.unitPrice, context),
                      style: GoogleFonts.notoSerif(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE2E2E2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF444444), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFE2E2E2),
          letterSpacing: 1,
        ),
      ),
    );
  }
}
