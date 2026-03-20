import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router_name.dart';
import '../../modules/cart/controllers/cart/cart_cubit.dart';
import '../../modules/cart/model/cart_product_model.dart';
import '../../modules/profile/controllers/address/address_cubit.dart';
import '../../modules/profile/model/address_model.dart';
import '../../utils/utils.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool termsAccepted = false;
  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AddressCubit>().getAddress();
    });
  }

  void _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
              surface: Colors.white,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.black),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _validateAndSubmit() {
    final errors = <String>[];
    if (selectedDate == null) errors.add('Please select a date');
    if (selectedTime == null) errors.add('Please select a time');
    if (_selectedAddress == null) errors.add('Please add or select an address');
    if (!termsAccepted) errors.add('Please accept the Terms and Conditions');

    if (errors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text('Missing Information', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(child: Text(e, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700))),
                        ],
                      ),
                    ))
                .toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.black)),
            ),
          ],
        ),
      );
      return;
    }

    context.read<CartCubit>().pickupAtStoreOrder(
          _formatDate(selectedDate!),
          _formatTime(selectedTime!),
          _selectedAddress!.id,
        );
  }

  void _resolveSelectedAddress(List<AddressModel> addresses) {
    if (_selectedAddress != null) {
      // Make sure our selected address still exists
      final exists = addresses.any((a) => a.id == _selectedAddress!.id);
      if (exists) return;
    }
    // Auto-select default billing or first address
    if (addresses.isNotEmpty) {
      final billing = addresses.where((a) => a.defaultBilling == 1);
      _selectedAddress = billing.isNotEmpty ? billing.first : addresses.first;
    } else {
      _selectedAddress = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final productList = cartCubit.cartResponseModel?.cartProducts ?? [];
    final summary = _calculateTotals(productList, cartCubit);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Select Date & Time',
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Schedule', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectDate,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black.withOpacity(0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Choose Date',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _selectTime,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.black.withOpacity(0.35)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      selectedTime != null
                          ? selectedTime!.format(context)
                          : 'Choose Time',
                      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Cart Items', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Expanded(
              child: productList.isEmpty
                  ? Center(child: Text('No items in cart', style: GoogleFonts.inter(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: productList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final item = productList[index];
                        final itemPrice = Utils.cartProductPrice(context, item).toStringAsFixed(1);
                        return _buildCartItem(item, itemPrice, cartCubit);
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text('Address', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            BlocBuilder<AddressCubit, AddressState>(
              builder: (context, addressState) {
                final addresses = context.read<AddressCubit>().address?.addresses ?? [];
                _resolveSelectedAddress(addresses);

                if (addressState is AddressStateLoading) {
                  return Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                  );
                }

                if (addresses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('No address on file.', style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13)),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, RouteNames.addressScreen);
                            if (mounted) context.read<AddressCubit>().getAddress();
                          },
                          child: Text('Add', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedAddress!.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(
                              [
                                _selectedAddress!.address,
                                _selectedAddress!.city?.name ?? '',
                                _selectedAddress!.countryState?.name ?? '',
                                _selectedAddress!.country?.name ?? '',
                              ].where((s) => s.isNotEmpty).join(', '),
                              style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showAddressPicker(addresses),
                        child: Text('Change', style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 8),
            _buildSummaryRow('Subtotal', Utils.formatPriceIcon(summary.subTotal.toStringAsFixed(2), context)),
            const SizedBox(height: 4),
            _buildSummaryRow('Discount', Utils.formatPriceIcon(summary.discount.toStringAsFixed(2), context)),
            const SizedBox(height: 4),
            _buildSummaryRow('Total', Utils.formatPriceIcon(summary.total.toStringAsFixed(2), context), isBold: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: termsAccepted,
                  activeColor: Colors.black,
                  checkColor: Colors.white,
                  side: BorderSide(color: Colors.black.withOpacity(0.35)),
                  onChanged: (v) => setState(() => termsAccepted = v ?? false),
                ),
                Expanded(
                  child: Text(
                    'I agree to all Terms and Conditions in OUI',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            BlocConsumer<CartCubit, CartState>(
              listener: (context, state) {
                if (state is CartStateOrderSuccess) {
                  Utils.showSnackBar(context, state.message);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.orderScreen,
                    (route) {
                      if (route.settings.name == RouteNames.mainPage) {
                        return true;
                      }
                      return false;
                    },
                  );
                } else if (state is CartStateError) {
                  Utils.errorSnackBar(context, state.message);
                }
              },
              builder: (context, cartState) {
                final isLoading = cartState is CartStateLoading;
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _validateAndSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade500,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Proceed for Approval', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  void _showAddressPicker(List<AddressModel> addresses) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Address', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
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
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.black.withOpacity(0.05) : Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected ? Border.all(color: Colors.black, width: 1.5) : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(
                            [
                              addr.address,
                              addr.city?.name ?? '',
                              addr.countryState?.name ?? '',
                              addr.country?.name ?? '',
                            ].where((s) => s.isNotEmpty).join(', '),
                            style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          if (addr.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(addr.phone, style: GoogleFonts.inter(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await Navigator.pushNamed(context, RouteNames.addressScreen);
                      if (mounted) context.read<AddressCubit>().getAddress();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Add New Address', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(CartProductModel item, String itemPrice, CartCubit cartCubit) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(item.product.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
              Text(Utils.formatPriceIcon(itemPrice, context), style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  if (item.qty > 1) {
                    cartCubit.decrementQuantity(item.productId.toString()).then((_) => setState(() {}));
                  }
                },
              ),
              Text(item.qty.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  cartCubit.incrementQuantity(item.productId.toString()).then((_) => setState(() {}));
                },
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  cartCubit.removerCartItem(item.productId.toString()).then((_) => setState(() {}));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: isBold ? Colors.black : Colors.grey.shade600,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: Colors.black,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
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
