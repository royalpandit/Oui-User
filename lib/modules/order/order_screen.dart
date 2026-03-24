import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/please_sign_in_widget.dart';
import 'controllers/order/order_cubit.dart';
import 'model/order_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderCubit>().getOrderList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<OrderCubit, OrderState>(
          builder: (context, state) {
            if (state is OrderStateLoading || state is OrderStateInitial) {
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
            } else if (state is OrderStateLoaded ||
                state is OrderSingleStateLoaded) {
              final orderList = context.read<OrderCubit>().orderList;
              return _OrderLoadedWidget(orderedList: orderList);
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class _OrderLoadedWidget extends StatefulWidget {
  final List<OrderModel> orderedList;

  const _OrderLoadedWidget({required this.orderedList});

  @override
  State<_OrderLoadedWidget> createState() => _OrderLoadedWidgetState();
}

class _OrderLoadedWidgetState extends State<_OrderLoadedWidget> {
  List<OrderModel> orderedList = [];
  int _currentIndex = 0;

  static const _tabLabels = ['PENDING', 'PROCESSING', 'DELIVERED'];

  void _filtering(int index) {
    orderedList.clear();
    _currentIndex = index;
    for (var element in widget.orderedList) {
      if (element.orderStatus.toString() == index.toString()) {
        orderedList.add(element);
      }
    }
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _filtering(_currentIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name ?? '';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (routeName != RouteNames.mainPage)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 18, color: Colors.white),
                    ),
                  ),
                Text(
                  'Order History',
                  style: GoogleFonts.notoSerif(
                    fontSize: 36,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.11,
                    letterSpacing: -0.9,
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: 0.50,
                  child: Text(
                    'L\'ART DE VIVRE \u2022 ARCHIVES',
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFA3A3A3),
                      height: 1.5,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Tab Bar ──
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                    color: Colors.white.withValues(alpha: 0.10), width: 1),
              ),
            ),
            child: Row(
              children: List.generate(_tabLabels.length, (i) {
                final isSelected = _currentIndex == i;
                return GestureDetector(
                  onTap: () => _filtering(i),
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: 12,
                      right: i < _tabLabels.length - 1 ? 24 : 0,
                    ),
                    decoration: BoxDecoration(
                      border: isSelected
                          ? const Border(
                              bottom:
                                  BorderSide(color: Colors.white, width: 1))
                          : null,
                    ),
                    child: Text(
                      _tabLabels[i],
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFA3A3A3),
                        height: 1.5,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),

        // ── Order Cards ──
        if (orderedList.isEmpty) ...[
          SliverToBoxAdapter(child: _buildEmptyState()),
        ] else ...[
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildOrderCard(orderedList[index]),
                  );
                },
                childCount: orderedList.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],

        // ── Browse Full Archive ──
        if (orderedList.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10), width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  'BROWSE FULL ARCHIVE',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.5,
                    letterSpacing: 2.7,
                  ),
                ),
              ),
            ),
          ),

        // ── Bottom Quote ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            child: Opacity(
              opacity: 0.40,
              child: Column(
                children: [
                  Container(
                    width: 16,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\u201CStyle is a way to say who you are without\nhaving to speak.\u201D',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerif(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.63,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 32,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
              height: routeName == RouteNames.mainPage ? 100 : 40),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 48, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 20),
          Text(
            'No Orders Yet',
            style: GoogleFonts.notoSerif(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your order history will appear here',
            style: GoogleFonts.manrope(
              fontSize: 12,
              color: const Color(0xFF777777),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, RouteNames.mainPage),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20), width: 1),
              ),
              child: Text(
                'EXPLORE COLLECTION',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  letterSpacing: 2.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(int status) {
    switch (status) {
      case 0:
        return 'PENDING';
      case 1:
        return 'PROCESSING';
      case 2:
        return 'DELIVERED';
      case 3:
        return 'COMPLETED';
      default:
        return 'DECLINED';
    }
  }

  Widget _buildOrderCard(OrderModel order) {
    final status = order.orderStatus;
    final statusText = _statusLabel(status);
    final isDelivered = status == 2 || status == 3;
    final isPending = status == 0;

    // Status badge styling
    Color badgeBg;
    Color badgeBorder;
    Color badgeText;
    if (isPending) {
      badgeBg = Colors.white;
      badgeBorder = Colors.white;
      badgeText = Colors.black;
    } else if (isDelivered) {
      badgeBg = Colors.transparent;
      badgeBorder = Colors.white.withValues(alpha: 0.10);
      badgeText = const Color(0xFFA3A3A3);
    } else {
      badgeBg = Colors.white.withValues(alpha: 0.10);
      badgeBorder = Colors.white.withValues(alpha: 0.20);
      badgeText = Colors.white;
    }

    final productName = order.orderProducts.isNotEmpty
        ? order.orderProducts.first.productName
        : 'Order #${order.orderId}';

    return Opacity(
      opacity: isDelivered ? 0.70 : 1.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.05), width: 1),
        ),
        child: Column(
          children: [
            // ── Top row: image + info + status badge ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Container(
                  width: 80,
                  height: 96,
                  clipBehavior: Clip.antiAlias,
                  decoration:
                      const BoxDecoration(color: Color(0xFF141414)),
                  child: order.orderProducts.isNotEmpty &&
                          order.orderProducts.first.thumbImage.isNotEmpty
                      ? CustomImage(
                          path: RemoteUrls.imageUrl(
                              order.orderProducts.first.thumbImage),
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.shopping_bag_outlined,
                          size: 24,
                          color: Colors.white.withValues(alpha: 0.20)),
                ),
                const SizedBox(width: 16),
                // Info column
                Expanded(
                  child: SizedBox(
                    height: 96,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSerif(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Color and Size info
                            if (order.orderProducts.isNotEmpty &&
                                order.orderProducts.first.color.isNotEmpty)
                              Text(
                                'Color: ${order.orderProducts.first.color}',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA3A3A3),
                                  letterSpacing: 0.45,
                                ),
                              ),
                            if (order.orderProducts.isNotEmpty &&
                                order.orderProducts.first.size.isNotEmpty)
                              Text(
                                'Size: ${order.orderProducts.first.size}',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA3A3A3),
                                  letterSpacing: 0.45,
                                ),
                              ),
                            const SizedBox(height: 2),
                            Opacity(
                              opacity: 0.60,
                              child: Text(
                                '#${order.orderId} \u2022 ${Utils.formatDate(order.createdAt).toUpperCase()}',
                                style: GoogleFonts.manrope(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFA3A3A3),
                                  height: 1.5,
                                  letterSpacing: 0.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          Utils.formatPrice(
                              order.totalAmount, context),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.33,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    border: Border.all(color: badgeBorder, width: 1),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.manrope(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeText,
                      height: 1.5,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // ── Action button ──
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context, RouteNames.singleOrderScreen,
                    arguments: order.orderId);
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white
                        .withValues(alpha: 0.20),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  isDelivered
                      ? 'ORDER AGAIN'
                      : 'TRACK JOURNEY',
                  style: GoogleFonts.manrope(
                    fontSize: 9,
                    fontWeight: FontWeight.w400,
                    color: isDelivered
                        ? Colors.white
                            .withValues(alpha: 0.40)
                        : Colors.white,
                    height: 1.5,
                    letterSpacing: 3.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
