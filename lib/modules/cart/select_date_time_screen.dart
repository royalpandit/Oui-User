import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../modules/cart/controllers/cart/cart_cubit.dart';
import '../../modules/cart/model/cart_product_model.dart';
import '../../modules/cart/order_confirmed_screen.dart';
import '../../modules/profile/controllers/address/address_cubit.dart';
import '../../modules/profile/model/address_model.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? selectedDate;
  String? selectedTimeSlot;
  bool termsAccepted = false;
  AddressModel? _selectedAddress;

  // Generate next 30 rolling days from today
  late final List<DateTime> _futureDays;
  static const List<String> _timeSlots = [
    '09:00 — 11:00',
    '12:00 — 14:00',
    '15:00 — 17:00',
    '18:00 — 20:00',
  ];

  static const List<String> _dayNames = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  static const List<String> _monthNames = [
    'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
    'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _futureDays = List.generate(30, (i) => now.add(Duration(days: i)));
    selectedDate = _futureDays[0];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AddressCubit>().getAddress();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeSlot(String slot) {
    // Extract start time from slot like "09:00 — 11:00"
    return slot.split(' ')[0];
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  void _validateAndSubmit() {
    final errors = <String>[];
    if (selectedDate == null) errors.add('Please select a date');
    if (selectedTimeSlot == null) errors.add('Please select a time slot');
    if (_selectedAddress == null) errors.add('Please add or select an address');
    if (!termsAccepted) errors.add('Please accept the Terms and Conditions');

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.7),
        builder: (ctx) => Dialog(
          backgroundColor: const Color(0xFF1B1B1B),
          shape: const RoundedRectangleBorder(),
          insetPadding: const EdgeInsets.symmetric(horizontal: 32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MISSING INFORMATION',
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: const Color(0xFFA0A0A0), letterSpacing: 2)),
                const SizedBox(height: 16),
                ...errors.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(width: 4, height: 4, color: const Color(0xFFFFB4AB)),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e, style: GoogleFonts.inter(
                              fontSize: 13, color: const Color(0xFFC7C6C6)))),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    color: Colors.white,
                    child: Center(
                      child: Text('OK', style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: const Color(0xFF131313), letterSpacing: 2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    context.read<CartCubit>().pickupAtStoreOrder(
          _formatDate(selectedDate!),
          _formatTimeSlot(selectedTimeSlot!),
          _selectedAddress!.id,
        );
  }

  void _resolveSelectedAddress(List<AddressModel> addresses) {
    if (_selectedAddress != null) {
      final exists = addresses.any((a) => a.id == _selectedAddress!.id);
      if (exists) return;
    }
    if (addresses.isNotEmpty) {
      final billing = addresses.where((a) => a.defaultBilling == 1);
      _selectedAddress = billing.isNotEmpty ? billing.first : addresses.first;
    } else {
      _selectedAddress = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final cartCubit = context.read<CartCubit>();
    final productList = cartCubit.cartResponseModel?.cartProducts ?? [];
    final summary = _calculateTotals(productList, cartCubit);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPadding + 64)),

              // Choose Date section
              SliverToBoxAdapter(child: _buildDateSection()),

              // Choose Time section
              SliverToBoxAdapter(child: _buildTimeSection()),

              // Your Selection (cart items)
              SliverToBoxAdapter(child: _buildSelectionSection(productList)),

              // Address section
              SliverToBoxAdapter(child: _buildAddressSection()),

              // Order Summary
              SliverToBoxAdapter(child: _buildOrderSummary(summary)),

              // Terms & Confirm button
              SliverToBoxAdapter(child: _buildConfirmSection()),

              SliverToBoxAdapter(child: const SizedBox(height: 40)),
            ],
          ),

          // App bar overlay
          Positioned(
            left: 0, right: 0, top: 0,
            child: Container(
              color: const Color(0xFF131313).withValues(alpha: 0.95),
              child: SafeArea(
                bottom: false,
                child: SizedBox(
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                        ),
                        const Spacer(),
                        Text(
                          'SCHEDULE DELIVERY',
                          style: GoogleFonts.notoSerif(
                            fontSize: 14, fontWeight: FontWeight.w300,
                            color: Colors.white, letterSpacing: 2.8,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    final currentMonth = selectedDate ?? _futureDays[0];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Choose Date', style: GoogleFonts.notoSerif(
                  fontSize: 24, fontWeight: FontWeight.w400,
                  color: Colors.white, height: 1.33, letterSpacing: -0.6)),
              Text(
                '${_monthNames[currentMonth.month - 1]} ${currentMonth.year}',
                style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w400,
                    color: const Color(0xFF777777), letterSpacing: 1, height: 1.5),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Horizontal scrollable day row
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _futureDays.length,
              separatorBuilder: (_, __) => const SizedBox(width: 0),
              itemBuilder: (_, index) {
                final day = _futureDays[index];
                final isSelected = selectedDate != null &&
                    day.year == selectedDate!.year &&
                    day.month == selectedDate!.month &&
                    day.day == selectedDate!.day;
                final isWeekend = _isWeekend(day);

                return GestureDetector(
                  onTap: isWeekend ? null : () => setState(() => selectedDate = day),
                  child: Opacity(
                    opacity: isWeekend ? 0.4 : 1.0,
                    child: Container(
                      width: 56,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      color: isSelected ? Colors.white : Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _dayNames[day.weekday - 1],
                            style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w400,
                              color: isSelected ? const Color(0xFF131313) : const Color(0xFF777777),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${day.day}',
                            style: GoogleFonts.notoSerif(
                              fontSize: 18, fontWeight: FontWeight.w400,
                              color: isSelected ? const Color(0xFF131313) : Colors.white,
                              height: 1.56,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose Time', style: GoogleFonts.notoSerif(
              fontSize: 24, fontWeight: FontWeight.w400,
              color: Colors.white, height: 1.33, letterSpacing: -0.6)),
          const SizedBox(height: 24),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _timeSlots.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, index) {
                final slot = _timeSlots[index];
                final isSelected = selectedTimeSlot == slot;
                return GestureDetector(
                  onTap: () => setState(() => selectedTimeSlot = slot),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFF444444), width: 1),
                    ),
                    child: Text(
                      slot,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w400,
                        color: isSelected ? const Color(0xFF131313) : const Color(0xFFE2E2E2),
                        letterSpacing: 1.2, height: 1.33,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionSection(List<CartProductModel> productList) {
    if (productList.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Selection', style: GoogleFonts.notoSerif(
              fontSize: 24, fontWeight: FontWeight.w400,
              color: Colors.white, height: 1.33, letterSpacing: -0.6)),
          const SizedBox(height: 32),
          ...productList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: _buildCartItem(item),
              )),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartProductModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        Container(
          width: 128,
          height: 170,
          color: const Color(0xFF181818),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: CustomImage(
              path: RemoteUrls.imageUrl(item.product.thumbImage),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 24),
        // Product info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.notoSerif(
                    fontSize: 18, fontWeight: FontWeight.w400,
                    color: Colors.white, height: 1.56, letterSpacing: 0.45,
                  ),
                ),
                const SizedBox(height: 4),
                // Variant details
                if (item.variants.isNotEmpty)
                  ...item.variants
                      .where((v) => v.varientItem != null)
                      .map((v) => Text(
                            '${v.varientItem!.productVariantName.toUpperCase()}: ${v.varientItem!.name.toUpperCase()}',
                            style: GoogleFonts.inter(
                              fontSize: 10, fontWeight: FontWeight.w400,
                              color: const Color(0xFF777777),
                              letterSpacing: 1, height: 1.5,
                            ),
                          )),
                if (item.variants.isEmpty)
                  Text(
                    'QTY: ${item.qty}',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: const Color(0xFF777777),
                      letterSpacing: 1, height: 1.5,
                    ),
                  ),
                // Selected sizes and colors
                if (item.selectedSizes.isNotEmpty ||
                    item.selectedColors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ...item.selectedSizes.map((s) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF444444), width: 1),
                              ),
                              child: Text(
                                'SIZE: ${s.toUpperCase()}',
                                style: GoogleFonts.inter(
                                  fontSize: 9, fontWeight: FontWeight.w400,
                                  color: const Color(0xFF777777),
                                  letterSpacing: 1,
                                ),
                              ),
                            )),
                        ...item.selectedColors.map((c) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF444444), width: 1),
                              ),
                              child: Text(
                                'COLOR: ${c.toUpperCase()}',
                                style: GoogleFonts.inter(
                                  fontSize: 9, fontWeight: FontWeight.w400,
                                  color: const Color(0xFF777777),
                                  letterSpacing: 1,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  Utils.formatPrice(
                    Utils.cartProductPrice(context, item),
                    context,
                  ),
                  style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w400,
                    color: Colors.white, height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Delivery Address', style: GoogleFonts.notoSerif(
              fontSize: 24, fontWeight: FontWeight.w400,
              color: Colors.white, height: 1.33, letterSpacing: -0.6)),
          const SizedBox(height: 24),
          BlocBuilder<AddressCubit, AddressState>(
            builder: (context, addressState) {
              final addresses = context.read<AddressCubit>().address?.addresses ?? [];
              _resolveSelectedAddress(addresses);

              if (addressState is AddressStateLoading) {
                return Container(
                  height: 50,
                  color: const Color(0xFF181818),
                  child: const Center(child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF444444))),
                );
              }

              if (addresses.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF444444), width: 1),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('No address on file.',
                            style: GoogleFonts.inter(color: const Color(0xFF777777), fontSize: 13)),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.pushNamed(context, RouteNames.addressScreen);
                          if (mounted) context.read<AddressCubit>().getAddress();
                        },
                        child: Text('ADD', style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w700,
                            fontSize: 11, letterSpacing: 1)),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF444444), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_selectedAddress!.name,
                              style: GoogleFonts.inter(fontWeight: FontWeight.w600,
                                  fontSize: 14, color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            [
                              _selectedAddress!.address,
                              _selectedAddress!.city?.name ?? '',
                              _selectedAddress!.countryState?.name ?? '',
                              _selectedAddress!.country?.name ?? '',
                            ].where((s) => s.isNotEmpty).join(', '),
                            style: GoogleFonts.inter(
                                color: const Color(0xFF777777), fontSize: 12, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showAddressPicker(addresses),
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 2),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF444444), width: 1)),
                        ),
                        child: Text('CHANGE', style: GoogleFonts.inter(
                            color: Colors.white, fontWeight: FontWeight.w600,
                            fontSize: 10, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartSummary summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Container(
        padding: const EdgeInsets.only(top: 32),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF262626), width: 1)),
        ),
        child: Column(
          children: [
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('SUBTOTAL', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w400,
                    color: const Color(0xFF777777), letterSpacing: 1, height: 1.5)),
                Text(
                  Utils.formatPrice(summary.subTotal, context),
                  style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w400,
                      color: Colors.white, height: 1.43),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Delivery fee
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('DELIVERY FEE', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w400,
                    color: const Color(0xFF777777), letterSpacing: 1, height: 1.5)),
                Text('COMPLIMENTARY', style: GoogleFonts.inter(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: Colors.white, letterSpacing: 1, height: 1.5)),
              ],
            ),
            if (summary.discount > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('DISCOUNT', style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: const Color(0xFF777777), letterSpacing: 1, height: 1.5)),
                  Text(
                    '-${Utils.formatPrice(summary.discount, context)}',
                    style: GoogleFonts.manrope(
                        fontSize: 14, fontWeight: FontWeight.w400,
                        color: const Color(0xFF4ADE80), height: 1.43),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TOTAL AMOUNT', style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w400,
                    color: Colors.white, height: 1.4, letterSpacing: -0.5)),
                Text(
                  Utils.formatPrice(summary.total, context),
                  style: GoogleFonts.notoSerif(
                      fontSize: 24, fontWeight: FontWeight.w400,
                      color: Colors.white, height: 1.33, letterSpacing: -0.6),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        children: [
          // Terms checkbox
          GestureDetector(
            onTap: () => setState(() => termsAccepted = !termsAccepted),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: termsAccepted ? Colors.white : const Color(0xFF444444),
                      width: 1,
                    ),
                    color: termsAccepted ? Colors.white : Colors.transparent,
                  ),
                  child: termsAccepted
                      ? const Icon(Icons.check, size: 14, color: Color(0xFF131313))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'I agree to all Terms and Conditions in OUI',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: const Color(0xFF777777), height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Confirm button
          BlocConsumer<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartStateOrderSuccess) {
                final cartCubit = context.read<CartCubit>();
                final products = cartCubit.cartResponseModel?.cartProducts ?? [];
                Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.orderConfirmedScreen,
                  (route) => route.settings.name == RouteNames.mainPage,
                  arguments: OrderConfirmedArgs(
                    selectedDate: selectedDate!,
                    address: _selectedAddress,
                    message: state.message,
                    orderId: state.orderId,
                    products: List.from(products),
                  ),
                );
              } else if (state is CartStateError) {
                Utils.errorSnackBar(context, state.message);
              }
            },
            builder: (context, cartState) {
              final isLoading = cartState is CartStateLoading;
              return GestureDetector(
                onTap: isLoading ? null : _validateAndSubmit,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: Colors.white,
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            height: 16, width: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Color(0xFF131313)),
                          )
                        : Text(
                            'CONFIRM SCHEDULE',
                            style: GoogleFonts.inter(
                              fontSize: 12, fontWeight: FontWeight.w700,
                              color: const Color(0xFF131313), letterSpacing: 3.6, height: 1.33,
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddressPicker(List<AddressModel> addresses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B1B1B),
      shape: const RoundedRectangleBorder(),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SELECT ADDRESS', style: GoogleFonts.inter(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: const Color(0xFFA0A0A0), letterSpacing: 2)),
                const SizedBox(height: 20),
                ...addresses.map((addr) {
                  final isSelected = _selectedAddress?.id == addr.id;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _selectedAddress = addr);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.white : const Color(0xFF444444),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr.name, style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 14,
                              color: isSelected ? const Color(0xFF131313) : Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            [
                              addr.address,
                              addr.city?.name ?? '',
                              addr.countryState?.name ?? '',
                              addr.country?.name ?? '',
                            ].where((s) => s.isNotEmpty).join(', '),
                            style: GoogleFonts.inter(
                                color: isSelected ? const Color(0xFF777777) : const Color(0xFF777777),
                                fontSize: 12, height: 1.5),
                          ),
                          if (addr.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(addr.phone, style: GoogleFonts.inter(
                                color: const Color(0xFF777777), fontSize: 11)),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    await Navigator.pushNamed(context, RouteNames.addressScreen);
                    if (mounted) context.read<AddressCubit>().getAddress();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF444444), width: 1),
                    ),
                    child: Center(
                      child: Text('ADD NEW ADDRESS', style: GoogleFonts.inter(
                          fontSize: 11, fontWeight: FontWeight.w700,
                          color: Colors.white, letterSpacing: 2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  CartSummary _calculateTotals(List<CartProductModel> productList, CartCubit cartCubit) {
    var subTotal = 0.0;
    for (var item in productList) {
      subTotal += Utils.cartProductPrice(context, item) * item.qty;
    }
    var discount = 0.0;
    if (cartCubit.couponResponseModel != null) {
      discount = double.tryParse(cartCubit.couponResponseModel!.discount) ?? 0.0;
    }
    final total = subTotal - discount;
    return CartSummary(subTotal: subTotal, discount: discount, total: total);
  }
}

class CartSummary {
  final double subTotal;
  final double discount;
  final double total;

  CartSummary({required this.subTotal, required this.discount, required this.total});
}
