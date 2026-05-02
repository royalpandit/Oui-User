import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../controllers/cart/cart_cubit.dart';
import '../model/cart_product_model.dart';

class CartItemCard extends StatelessWidget {
  const CartItemCard({
    super.key,
    required this.product,
    required this.appSetting,
    required this.onRemove,
    required this.onQuantityChanged,
  });

  final CartProductModel product;
  final AppSettingCubit appSetting;
  final ValueChanged<int> onRemove;
  final VoidCallback onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final resolvedColors = _resolvedColors();

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.productDetailsScreen,
              arguments: product.product.slug,
            ),
            child: Container(
              width: double.infinity,
              height: 320,
              color: const Color(0xFF181818),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CustomImage(
                  path: RemoteUrls.imageUrl(product.product.displayImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product info section
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Price row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.product.name.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.33,
                              letterSpacing: -0.6,
                            ),
                          ),
                          if (_attributeLabel().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              _attributeLabel().toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFFA0A0A0),
                                letterSpacing: 1,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      Utils.formatPrice(
                        Utils.cartProductPrice(context, product),
                        context,
                      ),
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Variant details
                if (product.variants.isNotEmpty) ...[
                  for (final v in product.variants)
                    if (v.varientItem != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${v.varientItem!.productVariantName.toUpperCase()}: ${v.varientItem!.name.toUpperCase()}',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFA0A0A0),
                                letterSpacing: 1.1,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                ],

                // Selected sizes and colors
                if (product.selectedSizes.isNotEmpty ||
                    resolvedColors.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (product.selectedSizes.isNotEmpty)
                          ...product.selectedSizes.map((s) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF444444), width: 1),
                                ),
                                child: Text(
                                  'SIZE: ${s.toUpperCase()}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFA0A0A0),
                                    letterSpacing: 1,
                                  ),
                                ),
                              )),
                        if (resolvedColors.isNotEmpty)
                          ...resolvedColors.map(_buildColorChip),
                      ],
                    ),
                  ),

                // Quantity +/- controls
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Text(
                        'QUANTITY',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFA0A0A0),
                          letterSpacing: 1.1,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      _QuantityControl(
                        productId: product.id.toString(),
                        initialQty: product.qty,
                        onQuantityChanged: onQuantityChanged,
                      ),
                    ],
                  ),
                ),

                // Actions row
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      // Edit button (navigate to product details)
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          RouteNames.productDetailsScreen,
                          arguments: product.product.slug,
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 4),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Color(0xFF444444), width: 1),
                            ),
                          ),
                          child: Text(
                            'EDIT',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 1,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Remove button
                      GestureDetector(
                        onTap: () async {
                          final result = await context
                              .read<CartCubit>()
                              .removerCartItem(product.id.toString());
                          result.fold(
                            (failure) =>
                                Utils.errorSnackBar(context, failure.message),
                            (success) {
                              onRemove(product.id);
                              Utils.showSnackBar(context, success);
                            },
                          );
                        },
                        child: Text(
                          'REMOVE',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xCCFFB4AB),
                            letterSpacing: 1,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _attributeLabel() {
    final labels = <String>[
      if (product.product.gender.trim().isNotEmpty)
        product.product.gender.trim(),
      if (product.product.clothType.trim().isNotEmpty)
        product.product.clothType.trim(),
    ];
    return labels.join(' / ');
  }

  List<String> _resolvedColors() {
    final colors = <String>{
      ...product.selectedColors.map((e) => e.trim()).where((e) => e.isNotEmpty),
    };

    for (final variant in product.variants) {
      final item = variant.varientItem;
      if (item == null) continue;
      final isColorType =
          item.productVariantName.toLowerCase().contains('color');
      if (isColorType && item.name.trim().isNotEmpty) {
        colors.add(item.name.trim());
      }
    }

    return colors.toList();
  }

  Widget _buildColorChip(String colorName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF444444), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Utils.parseColorLabel(colorName),
              border: Border.all(color: const Color(0xFF666666), width: 0.5),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'COLOR: ${colorName.toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFA0A0A0),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityControl extends StatefulWidget {
  const _QuantityControl({
    required this.productId,
    required this.initialQty,
    required this.onQuantityChanged,
  });

  final String productId;
  final int initialQty;
  final VoidCallback onQuantityChanged;

  @override
  State<_QuantityControl> createState() => _QuantityControlState();
}

class _QuantityControlState extends State<_QuantityControl> {
  late int _qty;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _qty = widget.initialQty;
  }

  @override
  void didUpdateWidget(covariant _QuantityControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialQty != widget.initialQty) {
      _qty = widget.initialQty;
    }
  }

  Future<void> _increment() async {
    if (_loading) return;
    setState(() => _loading = true);
    final result =
        await context.read<CartCubit>().incrementQuantity(widget.productId);
    result.fold(
      (failure) => Utils.errorSnackBar(context, failure.message),
      (_) {
        setState(() => _qty++);
        widget.onQuantityChanged();
      },
    );
    setState(() => _loading = false);
  }

  Future<void> _decrement() async {
    if (_loading || _qty <= 1) return;
    setState(() => _loading = true);
    final result =
        await context.read<CartCubit>().decrementQuantity(widget.productId);
    result.fold(
      (failure) => Utils.errorSnackBar(context, failure.message),
      (_) {
        setState(() => _qty--);
        widget.onQuantityChanged();
      },
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _decrement,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF444444), width: 1),
            ),
            alignment: Alignment.center,
            child: _loading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Color(0xFFA0A0A0),
                    ),
                  )
                : Text(
                    '−',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: _qty <= 1
                          ? const Color(0xFF444444)
                          : const Color(0xFFA0A0A0),
                      height: 1,
                    ),
                  ),
          ),
        ),
        Container(
          width: 40,
          height: 32,
          decoration: const BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: Color(0xFF444444), width: 1),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$_qty',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: _increment,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF444444), width: 1),
            ),
            alignment: Alignment.center,
            child: _loading
                ? const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: Color(0xFFA0A0A0),
                    ),
                  )
                : Text(
                    '+',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFFA0A0A0),
                      height: 1,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
