import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../modules/cart/model/cart_product_model.dart';
import '../../modules/profile/model/address_model.dart';
import '../../widgets/custom_image.dart';

class OrderConfirmedArgs {
  final DateTime selectedDate;
  final AddressModel? address;
  final String message;
  final String orderId;
  final List<CartProductModel> products;

  const OrderConfirmedArgs({
    required this.selectedDate,
    this.address,
    required this.message,
    this.orderId = '',
    required this.products,
  });
}

class OrderConfirmedScreen extends StatelessWidget {
  final OrderConfirmedArgs args;

  const OrderConfirmedScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Estimated delivery: selectedDate + 3 to selectedDate + 5 days
    final estStart = args.selectedDate.add(const Duration(days: 3));
    final estEnd = args.selectedDate.add(const Duration(days: 5));

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding + 40),
          child: Column(
            children: [
              // App bar
              SizedBox(
                height: 64,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                          RouteNames.mainPage,
                          (route) => false,
                        ),
                        child: const Icon(Icons.close, size: 20, color: Colors.white),
                      ),
                      const Spacer(),
                      Text(
                        'ORDER CONFIRMED',
                        style: GoogleFonts.notoSerif(
                          fontSize: 14, fontWeight: FontWeight.w300,
                          color: Colors.white, letterSpacing: 2.8,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Checkmark icon
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF444444), width: 1),
                ),
                child: const Center(
                  child: Icon(Icons.check, size: 40, color: Colors.white),
                ),
              ),

              const SizedBox(height: 40),

              // THANK YOU heading
              Text(
                'THANK YOU',
                style: GoogleFonts.notoSerif(
                  fontSize: 48, fontWeight: FontWeight.w300,
                  color: Colors.white, letterSpacing: 4.8, height: 1.08,
                ),
              ),

              const SizedBox(height: 16),

              // Order number
              Text(
                'ORDER PLACED SUCCESSFULLY',
                style: GoogleFonts.inter(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: const Color(0xFFA0A0A0), letterSpacing: 2, height: 1.45,
                ),
              ),

              const SizedBox(height: 24),

              // Description text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Your order has been placed and will be delivered\nwithin the estimated time. We\'ll notify you\nwhen it ships.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w400,
                    color: const Color(0xFF777777), height: 1.71,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // Arrival status card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF181818),
                    border: Border.all(color: const Color(0xFF262626), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ARRIVAL STATUS',
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w600,
                          color: const Color(0xFFA0A0A0), letterSpacing: 2, height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Product thumbnails row
                      if (args.products.isNotEmpty)
                        SizedBox(
                          height: 80,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: args.products.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (_, index) {
                              final item = args.products[index];
                              return Container(
                                width: 64,
                                height: 80,
                                color: const Color(0xFF1B1B1B),
                                padding: const EdgeInsets.all(6),
                                child: CustomImage(
                                  path: RemoteUrls.imageUrl(item.product.thumbImage),
                                  fit: BoxFit.contain,
                                ),
                              );
                            },
                          ),
                        ),

                      if (args.products.isNotEmpty)
                        const SizedBox(height: 24),

                      // Divider
                      Container(height: 1, color: const Color(0xFF262626)),

                      const SizedBox(height: 20),

                      // Estimated delivery
                      Text(
                        'ESTIMATED DELIVERY',
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w400,
                          color: const Color(0xFF777777), letterSpacing: 1, height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatEstDate(estStart)} — ${_formatEstDate(estEnd)}',
                        style: GoogleFonts.notoSerif(
                          fontSize: 18, fontWeight: FontWeight.w400,
                          color: Colors.white, height: 1.56,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Divider
                      Container(height: 1, color: const Color(0xFF262626)),

                      const SizedBox(height: 20),

                      // Shipping address
                      Text(
                        'SHIPPING ADDRESS',
                        style: GoogleFonts.inter(
                          fontSize: 10, fontWeight: FontWeight.w400,
                          color: const Color(0xFF777777), letterSpacing: 1, height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (args.address != null) ...[
                        Text(
                          args.address!.name,
                          style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600,
                            color: Colors.white, height: 1.43,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            args.address!.address,
                            args.address!.city?.name ?? '',
                            args.address!.countryState?.name ?? '',
                            args.address!.country?.name ?? '',
                          ].where((s) => s.isNotEmpty).join(', '),
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w400,
                            color: const Color(0xFF777777), height: 1.5,
                          ),
                        ),
                      ] else
                        Text(
                          'No address provided',
                          style: GoogleFonts.inter(
                            fontSize: 12, color: const Color(0xFF777777), height: 1.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // CONTINUE SHOPPING button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.mainPage,
                    (route) => false,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        'CONTINUE SHOPPING',
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: const Color(0xFF131313), letterSpacing: 3.6, height: 1.33,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // VIEW ORDER DETAILS button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GestureDetector(
                  onTap: () {
                    if (args.orderId.isNotEmpty) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteNames.singleOrderScreen,
                        (route) => route.settings.name == RouteNames.mainPage,
                        arguments: args.orderId,
                      );
                    } else {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        RouteNames.orderScreen,
                        (route) => route.settings.name == RouteNames.mainPage,
                      );
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF444444), width: 1),
                    ),
                    child: Center(
                      child: Text(
                        'VIEW ORDER DETAILS',
                        style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 3.6, height: 1.33,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // NEED ASSISTANCE link
              Text(
                'NEED ASSISTANCE? CONTACT CURATOR',
                style: GoogleFonts.inter(
                  fontSize: 10, fontWeight: FontWeight.w400,
                  color: const Color(0xFF777777), letterSpacing: 1.5, height: 1.5,
                  decoration: TextDecoration.underline,
                  decorationColor: const Color(0xFF777777),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const List<String> _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatEstDate(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.day}';
  }
}
