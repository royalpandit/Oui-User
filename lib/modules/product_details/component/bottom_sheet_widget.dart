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
import '../model/variant_items_model.dart';
import 'bottom_seet_product.dart';

class BottomSheetWidget extends StatefulWidget {
  const BottomSheetWidget({
    super.key,
    required this.product,
    this.initialSize,
    this.initialColor,
  });

  final ProductDetailsProductModel product;
  final String? initialSize;
  final String? initialColor;

  @override
  State<BottomSheetWidget> createState() => _BottomSheetWidgetState();
}

class _BottomSheetWidgetState extends State<BottomSheetWidget> {
  Set<ActiveVariantModel> variantItems = {};

  int quantity = 1;
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _variantsInit();
    _selectedSize = widget.initialSize;
    _selectedColor = widget.initialColor;
  }

  void _variantsInit() {
    for (var element in widget.product.activeVariantModel) {
      final item = element.activeVariantsItems.first;
      variantItems.add(element.copyWith(activeVariantsItems: [item]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
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
          // Size selection
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
                                    color: const Color(0xFF474747),
                                    width: 1),
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
          // Color selection
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
                      final isSelected = _selectedColor == color;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColor = color),
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
                                    color: const Color(0xFF474747),
                                    width: 1),
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
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                Language.quantity.capitalizeByWord(),
                style: GoogleFonts.inter(
                    fontSize: 15, color: const Color(0xFFE2E2E2), fontWeight: FontWeight.w600),
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
                        child: const Icon(Icons.remove, color: Color(0xFFE2E2E2), size: 18),
                      ),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: GoogleFonts.inter(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
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
                        child: const Icon(Icons.add, color: Color(0xFFE2E2E2), size: 18),
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
                style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF919191)),
              ),
              Text(
                totalPrice(),
                style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              final dataModel = AddToCartModel(
                image: widget.product.thumbImage,
                productId: widget.product.id,
                slug: widget.product.slug,
                quantity: quantity,
                token: '',
                color: _selectedColor ?? '',
                size: _selectedSize ?? '',
                variantItems: variantItems,
              );
              context.read<AddToCartCubit>().addToCart(dataModel);
            },
            child: Container(
              width: double.infinity,
              height: 52.0,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: Colors.black, size: 22.0),
                  const SizedBox(width: 8),
                  Text(
                    Language.addToCart.capitalizeByWord(),
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
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
    double price;
    double flashPrice = 0.0;
    double offerPrice = widget.product.offerPrice;
    double mainPrice = widget.product.price;

    final isFlashSale = appSetting.settingModel!.flashSaleProducts
        .contains(FlashSaleProductsModel(productId: widget.product.id));

    // Calculate the price based on the flash sale status
    if (isFlashSale) {
      final discount = appSetting.settingModel!.flashSale.offer / 100 * (offerPrice > 0 ? offerPrice : mainPrice);
      flashPrice = (offerPrice > 0 ? offerPrice : mainPrice) - discount;
      price = flashPrice;
    } else {
      // If offer price is 0, use the main price
      price = (offerPrice > 0 ? offerPrice : mainPrice);
    }

    // Update the price based on selected variant items
    for (var element in variantItems) {
      if (element.activeVariantsItems.isNotEmpty) {
        price += Utils.toDouble(element.activeVariantsItems.first.price.toString());
      }
    }

    // Calculate the final price based on quantity
    price *= quantity;

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
                    fontWeight: FontWeight.w600, fontSize: 16.0, color: Color(0xFFE2E2E2)),
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
          border: Border.all(color: isSelected ? Colors.white : const Color(0xFF474747)),
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
