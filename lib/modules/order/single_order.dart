import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../core/router_name.dart';
import '../../utils/utils.dart';
import '../../widgets/please_sign_in_widget.dart';
import 'controllers/order/order_cubit.dart';
import 'model/order_model.dart';
import 'model/product_order_model.dart';

class SingleOrderDetails extends StatefulWidget {
  const SingleOrderDetails({super.key, this.trackNumber});
  final String? trackNumber;

  @override
  State<SingleOrderDetails> createState() => _SingleOrderDetailsState();
}

class _SingleOrderDetailsState extends State<SingleOrderDetails> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => context.read<OrderCubit>().getSingleOrder(widget.trackNumber!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Order Details',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, state) {
          if (state is OrderStateLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2));
          } else if (state is OrderStateError) {
            if (state.statusCode == 401) {
              return const PleaseSignInWidget();
            }
            return Center(
              child: Text(state.message, style: GoogleFonts.inter(fontSize: 14, color: Colors.red)),
            );
          } else if (state is OrderSingleStateLoaded) {
            return _OrderDetailsBody(order: state.singleOrder);
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  const _OrderDetailsBody({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // ── Order Status Banner ──
        _buildStatusBanner(),
        const SizedBox(height: 8),

        // ── Products ──
        _buildSection(
          title: 'Products',
          child: Column(
            children: List.generate(order.orderProducts.length, (i) {
              final product = order.orderProducts[i];
              return Column(
                children: [
                  if (i > 0) Divider(height: 1, color: Colors.grey.shade200),
                  _ProductTile(product: product),
                ],
              );
            }),
          ),
        ),
        const SizedBox(height: 8),

        // ── Order Summary ──
        _buildSection(
          title: 'Price Details',
          child: Column(
            children: [
              _buildSummaryRow('Subtotal (${order.productQty} item${order.productQty > 1 ? 's' : ''})',
                  Utils.formatPrice(order.totalAmount - order.shippingCost + order.couponCoast, context)),
              if (order.couponCoast > 0)
                _buildSummaryRow('Coupon Discount', '- ${Utils.formatPrice(order.couponCoast, context)}',
                    valueColor: const Color(0xFF388E3C)),
              _buildSummaryRow('Delivery (${order.shippingMethod})', Utils.formatPrice(order.shippingCost, context)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Colors.grey.shade200),
              ),
              _buildSummaryRow('Total Amount', Utils.formatPrice(order.totalAmount, context), isBold: true),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Payment Info ──
        _buildSection(
          title: 'Payment',
          child: Column(
            children: [
              _buildInfoRow('Method', order.paymentMethod),
              _buildInfoRow('Status', order.paymentStatus == 1 ? 'Paid' : 'Unpaid',
                  valueColor: order.paymentStatus == 1 ? const Color(0xFF388E3C) : Colors.orange.shade700),
              if (order.cashOnDelivery == 1)
                _buildInfoRow('Type', 'Cash on Delivery'),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Delivery Address ──
        if (order.orderAddress != null) ...[
          _buildSection(
            title: 'Delivery Address',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderAddress!.billingName,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  order.orderAddress!.billingAddress,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
                ),
                Text(
                  '${order.orderAddress!.billingCity}, ${order.orderAddress!.billingState}',
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                ),
                Text(
                  order.orderAddress!.billingCountry,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      order.orderAddress!.billingPhone,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      order.orderAddress!.billingEmail,
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // ── Order Info ──
        _buildSection(
          title: 'Order Info',
          child: Column(
            children: [
              _buildInfoRow('Order ID', '#${order.orderId}'),
              _buildInfoRow('Placed on', Utils.formatDate(order.createdAt)),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildStatusBanner() {
    final statusText = Utils.orderStatus(order.orderStatus.toString());
    final isDeclined = order.orderStatus == 4;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDeclined ? const Color(0xFFFFF3F3) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDeclined ? const Color(0xFFFFCDD2) : const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: isDeclined ? const Color(0xFFFFEBEE) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDeclined ? Icons.cancel_outlined : _statusIcon(order.orderStatus),
              size: 20,
              color: isDeclined ? Colors.red.shade400 : Colors.black,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDeclined ? Colors.red.shade600 : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusSubtitle(order.orderStatus),
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(int status) {
    switch (status) {
      case 0: return Icons.hourglass_empty_rounded;
      case 1: return Icons.check_circle_outline_rounded;
      case 2: return Icons.local_shipping_outlined;
      case 3: return Icons.inventory_2_outlined;
      default: return Icons.info_outline_rounded;
    }
  }

  String _statusSubtitle(int status) {
    switch (status) {
      case 0: return 'Your order is awaiting confirmation';
      case 1: return 'Your order has been approved';
      case 2: return 'Your order is on the way';
      case 3: return 'Your order has been delivered';
      case 4: return 'Your order was declined';
      default: return '';
    }
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: valueColor ?? Colors.black),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final OrderedProductModel product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product icon placeholder
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shopping_bag_outlined, size: 22, color: Colors.black38),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${product.qty}',
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Utils.formatPrice(product.unitPrice, context),
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.submitFeedBackScreen, arguments: product);
                },
                child: Text(
                  'Write Review',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
