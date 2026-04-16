import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/utils/language_string.dart';
import 'package:shop_us/widgets/capitalized_word.dart';

import '../../../utils/utils.dart';
import '../../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../../cart/controllers/cart/add_to_cart/add_to_cart_cubit.dart';
import '../../cart/model/add_to_cart_model.dart';
import '../../home/model/product_model.dart';
import '../../setting/model/website_setup_model.dart';
import '../model/product_details_product_model.dart';
import '../model/product_variant_model.dart';
import '../model/variant_detail_model.dart';
import '../model/variant_items_model.dart';
import 'bottom_seet_product.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    super.key,
    required this.product,
    this.initialSize,
    this.initialColorKey,
    this.initialVariantId,
  });

  final ProductDetailsProductModel product;
  final String? initialSize;
  final String? initialColorKey;
  final int? initialVariantId;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  Set<ActiveVariantModel> variantItems = {};

  int quantity = 1;
  String? _selectedSize;
  String? _selectedColorKey;
  int? _selectedVariantId;

  @override
  void initState() {
    super.initState();
    _variantsInit();
    _selectedSize = widget.initialSize;
    _selectedColorKey = widget.initialColorKey;
    _selectedVariantId = widget.initialVariantId;
    _applyDefaultVariantSelection();
  }

  void _variantsInit() {
    for (var element in widget.product.activeVariantModel) {
      if (element.activeVariantsItems.isEmpty) continue;
      final item = element.activeVariantsItems.first;
      variantItems.add(element.copyWith(activeVariantsItems: [item]));
    }
  }

  String _colorKey(VariantDetailModel item) {
    final code = item.colorCode.trim().toLowerCase();
    if (code.isNotEmpty) return code;
    return item.color.trim().toLowerCase();
  }

  Map<String, List<VariantDetailModel>> _groupedByColor() {
    final grouped = <String, List<VariantDetailModel>>{};
    for (final item in widget.product.variantDetails) {
      final key = _colorKey(item);
      grouped.putIfAbsent(key, () => <VariantDetailModel>[]).add(item);
    }
    return grouped;
  }

  VariantDetailModel? _resolveVariant() {
    final variants = widget.product.variantDetails;
    if (variants.isEmpty) return null;

    if ((_selectedVariantId ?? 0) > 0) {
      for (final item in variants) {
        if (item.id == _selectedVariantId) return item;
      }
    }

    if (_selectedColorKey != null) {
      for (final item in variants) {
        if (_colorKey(item) == _selectedColorKey &&
            (_selectedSize == null ||
                item.size.trim().toLowerCase() ==
                    _selectedSize!.trim().toLowerCase())) {
          return item;
        }
      }
    }

    return variants.first;
  }

  void _applyDefaultVariantSelection() {
    final selected = _resolveVariant();
    if (selected == null) return;
    _selectedVariantId = selected.id;
    _selectedColorKey = _colorKey(selected);
    _selectedSize = selected.size;
  }

  Color _parseColor(String colorCode) {
    final raw = colorCode.trim();
    if (raw.isEmpty) return const Color(0xFF666666);
    String hex = raw.startsWith('#') ? raw.substring(1) : raw;
    if (hex.length == 6) hex = 'FF$hex';
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xFF666666);
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            color: const Color(0xFF474747),
          ),
          BottomSheetProduct(
            product: ProductModel.fromMap(
              widget.product.toMap(),
            ),
            variantItem: variantItems,
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 24),
          if (widget.product.variantDetails.isEmpty)
            _VarientItemsWidget(
              productVariants: widget.product.activeVariantModel,
              variantItems: variantItems,
              onChange: (item) {
                setState(() {
                  for (var element in variantItems.toList()) {
                    if (element.id == item.id) {
                      variantItems.remove(element);
                    }
                  }
                  variantItems.add(item);
                });
              },
            ),
          if (widget.product.variantDetails.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildColorSelector(),
            const SizedBox(height: 12),
            _buildSizeSelector(),
          ] else if (widget.product.sizes.isNotEmpty ||
              widget.product.colors.isNotEmpty) ...[
            // Legacy Size selection
            if (widget.product.sizes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Size :',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFFE2E2E2)),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.sizes.map((size) {
                        final isSelected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedSize = size),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFF474747), width: 1),
                            ),
                            child: Text(
                              size.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: isSelected
                                    ? Colors.black
                                    : const Color(0xFFE2E2E2),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
            // Legacy Color selection
            if (widget.product.colors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      'Color :',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: const Color(0xFFE2E2E2)),
                    ),
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.product.colors.map((color) {
                        final isSelected =
                            _selectedColorKey == color.toLowerCase();
                        return GestureDetector(
                          onTap: () => setState(
                              () => _selectedColorKey = color.toLowerCase()),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: const Color(0xFF474747), width: 1),
                            ),
                            child: Text(
                              color.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: isSelected
                                    ? Colors.black
                                    : const Color(0xFFE2E2E2),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                Language.quantity.capitalizeByWord(),
                style: GoogleFonts.inter(
                    fontSize: 15,
                    color: const Color(0xFFE2E2E2),
                    fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                color: const Color(0xFF2A2A2A),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (quantity > 1) {
                          quantity--;
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(Icons.remove,
                            color: Color(0xFFE2E2E2), size: 18),
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        quantity++;
                        setState(() {});
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        child: const Icon(Icons.add,
                            color: Color(0xFFE2E2E2), size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.totalPrice.capitalizeByWord(),
                style: GoogleFonts.inter(
                    fontSize: 14, color: const Color(0xFF919191)),
              ),
              Text(
                totalPrice(),
                style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              final dataModel = AddToCartModel(
                image: widget.product.thumbImage,
                productId: widget.product.id,
                slug: widget.product.slug,
                quantity: quantity,
                token: '',
                color: _resolveVariant()?.color ?? '',
                size: _selectedSize ?? '',
                variantId: _resolveVariant()?.id,
                variantItems: variantItems,
              );
              context.read<AddToCartCubit>().addToCart(dataModel);
              Navigator.pop<Map<String, String?>>(context, {
                'size': _selectedSize,
                'color_key': _selectedColorKey,
                'variant_id': (_resolveVariant()?.id ?? 0).toString(),
              });
            },
            child: Container(
              width: double.infinity,
              height: 52.0,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined,
                      color: Colors.black, size: 22.0),
                  const SizedBox(width: 8),
                  Text(
                    Language.addToCart.capitalizeByWord(),
                    style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    final grouped = _groupedByColor();
    final entries = grouped.entries.toList();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            'Color :',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: const Color(0xFFE2E2E2)),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: entries.map((entry) {
              final first = entry.value.first;
              final isSelected = _selectedColorKey == entry.key;
              final label = first.color.trim().isNotEmpty
                  ? first.color.trim()
                  : first.name.trim();
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColorKey = entry.key;
                    _selectedSize = first.size;
                    _selectedVariantId = first.id;
                  });
                },
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _parseColor(first.colorCode),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF474747),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFE2E2E2),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSizeSelector() {
    final grouped = _groupedByColor();
    final currentColor = _selectedColorKey;
    final variants = currentColor != null && grouped.containsKey(currentColor)
        ? grouped[currentColor]!
        : <VariantDetailModel>[];
    final sizes = variants
        .map((e) => e.size.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            'Size :',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: const Color(0xFFE2E2E2)),
          ),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sizes.map((size) {
              final isSelected = _selectedSize == size;
              return GestureDetector(
                onTap: () {
                  final selected = variants
                      .where((v) =>
                          v.size.trim().toLowerCase() == size.toLowerCase())
                      .toList();
                  if (selected.isEmpty) return;
                  setState(() {
                    _selectedSize = size;
                    _selectedVariantId = selected.first.id;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    border: Border.all(
                        color:
                            isSelected ? Colors.white : const Color(0xFF474747),
                        width: 1),
                  ),
                  child: Text(
                    size.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color:
                          isSelected ? Colors.black : const Color(0xFFE2E2E2),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  /*String totalPrice() {
    double price;
    if(widget.product.offerPrice.isNotEmpty){
      price = Utils.toDouble(widget.product.offerPrice) * quantity;
    }else{
      price = Utils.toDouble(widget.product.price) * quantity;

    }


    for (var element in variantItems) {
      if (element.variantItems.isNotEmpty) {
        price += Utils.toDouble(element.variantItems.first.price);
      }
    }
    return Utils.formatPrice(price);
  }*/

  // String totalPrice() {
  //   final appSetting = context.read<AppSettingCubit>();
  //   double flashPrice = 0.0;
  //   double offerPrice = 0.0;
  //   double mainPrice = 0.0;
  //   double price;
  //   final isFlashSale = appSetting.settingModel!.flashSaleProducts
  //       .contains(FlashSaleProductsModel(productId: widget.product.id));
  //   if (widget.product.offerPrice.toString().isNotEmpty) {
  //     if (widget.product.activeVariantModel.isNotEmpty) {
  //       double p = 0.0;
  //       for (var i in widget.product.activeVariantModel) {
  //         if (i.activeVariantsItems.isNotEmpty) {
  //           // p += Utils.toDouble(i.activeVariantsItems.first.price);
  //         }
  //       }
  //       offerPrice = p + widget.product.offerPrice;
  //     } else {
  //       offerPrice = widget.product.offerPrice;
  //     }
  //   }
  //   if (widget.product.activeVariantModel.isNotEmpty) {
  //     double p = 0.0;
  //     for (var i in widget.product.activeVariantModel) {
  //       if (i.activeVariantsItems.isNotEmpty) {
  //         // p += Utils.toDouble(i.activeVariantsItems.first.price);
  //       }
  //     }
  //     mainPrice = p + widget.product.price;
  //   } else {
  //     mainPrice = widget.product.price;
  //   }
  //   if (isFlashSale) {
  //     if (widget.product.offerPrice.toString().isNotEmpty) {
  //       final discount =
  //           appSetting.settingModel!.flashSale.offer / 100 * offerPrice;
  //
  //       flashPrice = offerPrice - discount;
  //     } else {
  //       final discount =
  //           appSetting.settingModel!.flashSale.offer / 100 * mainPrice;
  //
  //       flashPrice = mainPrice - discount;
  //     }
  //     price = Utils.toDouble(flashPrice.toString()) * quantity;
  //   } else {
  //     if (widget.product.offerPrice.toString().isNotEmpty) {
  //       price = Utils.toDouble(offerPrice.toString()) * quantity;
  //     } else {
  //       price = Utils.toDouble(mainPrice.toString()) * quantity;
  //     }
  //   }
  //
  //   for (var element in variantItems) {
  //     if (element.activeVariantsItems.isNotEmpty) {
  //       price +=
  //           Utils.toDouble(element.activeVariantsItems.first.price.toString());
  //     }
  //   }
  //   return Utils.formatPrice(price, context);
  // }
  String totalPrice() {
    final appSetting = context.read<AppSettingCubit>();
    double unitPrice;
    double flashPrice = 0.0;

    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: widget.product.id));

    // In variant-details mode, price comes from the selected variant row.
    if (widget.product.variantDetails.isNotEmpty) {
      final selectedVariant = _resolveVariant();
      unitPrice = selectedVariant?.price ?? 0.0;
    } else {
      // Legacy variant schema keeps the old combined behavior.
      if (widget.product.offerPrice > 0) {
        if (variantItems.isNotEmpty) {
          double p = 0.0;
          for (var i in variantItems) {
            if (i.activeVariantsItems.isNotEmpty) {
              p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
            }
          }
          unitPrice = p + widget.product.offerPrice;
        } else {
          unitPrice = widget.product.offerPrice;
        }
      } else {
        if (variantItems.isNotEmpty) {
          double p = 0.0;
          for (var i in variantItems) {
            if (i.activeVariantsItems.isNotEmpty) {
              p += Utils.toDouble(i.activeVariantsItems.first.price.toString());
            }
          }
          unitPrice = p + widget.product.price;
        } else {
          unitPrice = widget.product.price;
        }
      }
    }

    if (isFlashSale && unitPrice > 0) {
      final discount =
          appSetting.settingModel!.flashSale.offer / 100 * unitPrice;
      flashPrice = unitPrice - discount;
      unitPrice = flashPrice;
    }

    // Calculate the final price based on quantity
    final price = unitPrice * quantity;

    return Utils.formatPrice(price, context);
  }
}

class _VarientItemsWidget extends StatelessWidget {
  const _VarientItemsWidget({
    required this.productVariants,
    required this.variantItems,
    required this.onChange,
  });

  final List<ActiveVariantModel> productVariants;
  final Set<ActiveVariantModel> variantItems;

  final ValueChanged<ActiveVariantModel> onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: productVariants.map(_buildSIngleVarient).toList(),
    );
  }

  Widget _buildSIngleVarient(ActiveVariantModel singleVarient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (singleVarient.activeVariantsItems.isNotEmpty) ...[
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Text(
                "${singleVarient.name} : ",
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16.0,
                    color: Color(0xFFE2E2E2)),
              ),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Wrap(
                children: singleVarient.activeVariantsItems.map(
                  (itemModel) {
                    return _buildVarientItemBox(singleVarient, itemModel);
                  },
                ).toList(),
              ),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildVarientItemBox(
    ActiveVariantModel singleVariant,
    ActiveVariantItemModel itemModel,
  ) {
    final varient = singleVariant.copyWith(activeVariantsItems: [itemModel]);
    final isSelected = variantItems.contains(varient);
    return InkWell(
      onTap: () => onChange(varient),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          border: Border.all(
              color: isSelected ? Colors.white : const Color(0xFF474747)),
        ),
        child: Text(
          itemModel.name.capitalizeByWord(),
          style: TextStyle(
            color: isSelected ? Colors.black : const Color(0xFFC7C6C6),
          ),
        ),
      ),
    );
  }
}
