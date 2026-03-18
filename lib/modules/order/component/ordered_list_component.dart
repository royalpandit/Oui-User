import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/widgets/capitalized_word.dart';

import '/utils/k_images.dart';
import '/widgets/custom_image.dart';
import '../../../core/router_name.dart';
import '../../../utils/language_string.dart';
import '../../../utils/utils.dart';
import '../model/order_model.dart';

class OrderedListComponent extends StatelessWidget {
  const OrderedListComponent({super.key, required this.orderedItem});

  final OrderModel orderedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _totalItem(context),
          const SizedBox(height: 10),
          _buildOrderNumber(context),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.black, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      Navigator.pushNamed(context, RouteNames.singleOrderScreen,
                          arguments: orderedItem.orderId);
                    },
                    child: Text(
                      Language.viewDetails.capitalizeByWord(),
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black),
                    )),
                Text(
                  Utils.orderStatus(orderedItem.orderStatus.toString()),
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: orderedItem.orderStatus.toString() == '4'
                          ? Colors.grey.shade700
                          : Colors.black),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalItem(BuildContext context) {
    final total = Utils.formatPriceIcon(orderedItem.totalAmount, context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: "${Language.quantity.capitalizeByWord()}: ",
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                      children: [
                        TextSpan(
                          text: orderedItem.productQty.toString(),
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text.rich(
                    TextSpan(
                      text: "${Language.totalAmount.capitalizeByWord()}: ",
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
                      children: [
                        TextSpan(
                          text: total,
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text(
                  Utils.formatDate(orderedItem.createdAt),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget buildImage() {
    return Container(
      width: 70,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const CustomImage(path: KImages.female),
    );
  }

  Widget _buildOrderNumber(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrackingNumber(),
        ],
      ),
    );
  }

  Widget _buildTrackingNumber() {
    return Text.rich(
      TextSpan(
        text: "${Language.orderTrackingNumber.capitalizeByWord()}: ",
        style: GoogleFonts.inter(
          fontSize: 14,
          color: Colors.grey.shade600,
          decoration: TextDecoration.underline,
        ),
        children: [
          TextSpan(
            text: ' ${orderedItem.orderId}',
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black, decoration: TextDecoration.none),
          ),
        ],
      ),
    );
  }
}
