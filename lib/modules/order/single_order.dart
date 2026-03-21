import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar ──
            Container(
              width: double.infinity,
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF131313).withValues(alpha: 0.80),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'ORDER DETAILS',
                    style: GoogleFonts.notoSerif(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.43,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
            ),
            // ── Body ──
            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is OrderStateLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 1.5));
                  } else if (state is OrderStateError) {
                    if (state.statusCode == 401) {
                      return const PleaseSignInWidget();
                    }
                    return Center(
                      child: Text(state.message,
                          style: GoogleFonts.inter(
                              fontSize: 14, color: Colors.red.shade300)),
                    );
                  } else if (state is OrderSingleStateLoaded) {
                    return _OrderDetailsBody(order: state.singleOrder);
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 128),
      children: [
        // ── Status + Order Number ──
        _buildHeader(),
        const SizedBox(height: 24),

        // ── Delivery Date ──
        _buildDeliveryDate(),
        const SizedBox(height: 64),

        // ── Tracking Progress ──
        _buildTrackingProgress(),
        const SizedBox(height: 64),

        // ── Products Section ──
        _buildProductsSection(context),
        const SizedBox(height: 64),

        // ── Shipping & Payment ──
        _buildShippingAndPayment(context),
        const SizedBox(height: 64),

        // ── Summary Card ──
        _buildSummaryCard(context),
      ],
    );
  }

  Widget _buildHeader() {
    final statusText = _statusLabel(order.orderStatus);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS: $statusText',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF5E5E5E),
            height: 1.33,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '#${order.orderId}',
          style: GoogleFonts.notoSerif(
            fontSize: 36,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            height: 1.11,
            letterSpacing: -0.9,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryDate() {
    final dateStr = order.orderDeliveredDate.isNotEmpty
        ? Utils.formatDate(order.orderDeliveredDate)
        : order.orderApprovalDate.isNotEmpty
            ? Utils.formatDate(order.orderApprovalDate)
            : Utils.formatDate(order.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          order.orderStatus >= 2 ? 'DELIVERY DATE' : 'ORDER DATE',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF777777),
            height: 1.5,
            letterSpacing: 1,
          ),
        ),
        Text(
          dateStr,
          style: GoogleFonts.notoSerif(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFE2E2E2),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingProgress() {
    final steps = ['CONFIRMED', 'SHIPPED', 'DELIVERED'];
    // Map orderStatus to progress: 0=Pending→step0, 1=Approved→step0, 2=Shipped→step1, 3=Delivered→step2
    int completedSteps;
    switch (order.orderStatus) {
      case 0:
        completedSteps = 0;
        break;
      case 1:
        completedSteps = 1;
        break;
      case 2:
        completedSteps = 2;
        break;
      case 3:
        completedSteps = 3;
        break;
      default:
        completedSteps = 0;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Progress bar with dots
          SizedBox(
            height: 38,
            child: Stack(
              children: [
                // Background line
                Positioned(
                  left: 0,
                  right: 0,
                  top: 5,
                  child: Container(
                    height: 1,
                    color: const Color(0xFF444444),
                  ),
                ),
                // Active line
                if (completedSteps > 0)
                  Positioned(
                    left: 0,
                    top: 5,
                    child: Container(
                      height: 1,
                      width: completedSteps >= steps.length
                          ? double.infinity
                          : null,
                      color: Colors.white,
                    ),
                  ),
                // Step dots and labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(steps.length, (i) {
                    final isActive = i < completedSteps;
                    return Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color:
                                isActive ? Colors.white : const Color(0xFF444444),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          steps[i],
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w400,
                            color: isActive
                                ? const Color(0xFFE2E2E2)
                                : const Color(0xFF555555),
                            height: 1.5,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: Color(0x4C444444), width: 1),
            ),
          ),
          child: Text(
            'YOUR SELECTION',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFE2E2E2),
              height: 1.56,
              letterSpacing: 1.8,
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Product items
        ...List.generate(order.orderProducts.length, (i) {
          final product = order.orderProducts[i];
          return Padding(
            padding: EdgeInsets.only(
                bottom: i < order.orderProducts.length - 1 ? 32 : 0),
            child: _buildProductItem(product, context),
          );
        }),
      ],
    );
  }

  Widget _buildProductItem(OrderedProductModel product, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image placeholder
        Container(
          width: 128,
          height: 176,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
          alignment: Alignment.center,
          child: Icon(Icons.shopping_bag_outlined,
              size: 32, color: Colors.white.withValues(alpha: 0.15)),
        ),
        const SizedBox(width: 32),
        // Product info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${product.qty}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF5E5E5E),
                    height: 1.33,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Write review
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                            context, RouteNames.submitFeedBackScreen,
                            arguments: product);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        color: const Color(0xFF262626),
                        child: Text(
                          'WRITE REVIEW',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE2E2E2),
                            height: 1.5,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    // Price
                    Text(
                      Utils.formatPrice(product.unitPrice, context),
                      style: GoogleFonts.notoSerif(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFE2E2E2),
                        height: 1.56,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingAndPayment(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 32),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x4C444444), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Shipping Address ──
          Text(
            'SHIPPING ADDRESS',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF777777),
              height: 1.5,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          if (order.orderAddress != null) ...[
            Text(
              order.orderAddress!.billingName,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFE2E2E2),
                height: 1.63,
              ),
            ),
            Text(
              order.orderAddress!.billingAddress,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE2E2E2),
                height: 1.63,
              ),
            ),
            Text(
              '${order.orderAddress!.billingCity}, ${order.orderAddress!.billingState}',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE2E2E2),
                height: 1.63,
              ),
            ),
            Text(
              order.orderAddress!.billingCountry,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE2E2E2),
                height: 1.63,
              ),
            ),
          ] else
            Text(
              'No address provided',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: const Color(0xFF777777),
              ),
            ),

          const SizedBox(height: 32),

          // ── Payment Method ──
          Text(
            'PAYMENT METHOD',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF777777),
              height: 1.5,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.credit_card,
                  size: 20, color: Colors.white.withValues(alpha: 0.50)),
              const SizedBox(width: 12),
              Text(
                order.cashOnDelivery == 1
                    ? 'Cash on Delivery'
                    : order.paymentMethod,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE2E2E2),
                  height: 1.43,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final subtotal = order.totalAmount - order.shippingCost + order.couponCoast;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(33),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color(0x33444444), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            'SUMMARY',
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFE2E2E2),
              height: 1.56,
              letterSpacing: 1.8,
            ),
          ),
          const SizedBox(height: 32),

          // Summary rows
          _buildSummaryRow('SUBTOTAL',
              Utils.formatPrice(subtotal, context)),
          const SizedBox(height: 16),
          _buildSummaryRow(
              'SHIPPING',
              order.shippingCost > 0
                  ? Utils.formatPrice(order.shippingCost, context)
                  : 'FREE',
              valueBold: order.shippingCost == 0),
          const SizedBox(height: 16),
          if (order.couponCoast > 0) ...[
            _buildSummaryRow('DISCOUNT',
                '- ${Utils.formatPrice(order.couponCoast, context)}',
                valueColor: const Color(0xFF4CAF50)),
            const SizedBox(height: 16),
          ],

          // Divider + Total
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x4C444444), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE2E2E2),
                    height: 1.4,
                  ),
                ),
                Text(
                  Utils.formatPrice(order.totalAmount, context),
                  style: GoogleFonts.notoSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE2E2E2),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Reorder Button ──
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, RouteNames.mainPage),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.white,
              alignment: Alignment.center,
              child: Text(
                'REORDER ITEMS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF131313),
                  height: 1.5,
                  letterSpacing: 2.75,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Track Package Button ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF777777), width: 1),
            ),
            alignment: Alignment.center,
            child: Text(
              'TRACK PACKAGE',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white,
                height: 1.5,
                letterSpacing: 2.75,
              ),
            ),
          ),

          const SizedBox(height: 40),

          // ── Need Assistance ──
          Center(
            child: Column(
              children: [
                Text(
                  'NEED ASSISTANCE?',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF777777),
                    height: 1.5,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E2E2), width: 1),
                    ),
                  ),
                  child: Text(
                    'CONTACT CONCIERGE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFE2E2E2),
                      height: 1.5,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF5E5E5E),
            height: 1.33,
            letterSpacing: 0.3,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w400,
            color: valueColor ?? const Color(0xFFE2E2E2),
            height: 1.33,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  String _statusLabel(int status) {
    switch (status) {
      case 0:
        return 'PENDING';
      case 1:
        return 'PROCESSING';
      case 2:
        return 'SHIPPED';
      case 3:
        return 'DELIVERED';
      default:
        return 'DECLINED';
    }
  }
}
