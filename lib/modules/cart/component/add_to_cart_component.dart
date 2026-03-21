import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_us/widgets/custom_text.dart';

import '/modules/animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '/widgets/capitalized_word.dart';
import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/language_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../controllers/cart/cart_cubit.dart';
import '../model/cart_product_model.dart';

class AddToCartComponent extends StatefulWidget {
  const AddToCartComponent(
      {super.key,
      required this.product,
      required this.onChange,
      required this.appSetting});

  final CartProductModel product;
  final ValueChanged<int> onChange;
  final AppSettingCubit appSetting;

  @override
  State<AddToCartComponent> createState() => _AddToCartComponentState();
}

class _AddToCartComponentState extends State<AddToCartComponent> {
  @override
  Widget build(BuildContext context) {
    const double height = 120;

    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: const BoxDecoration(
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
        ),
        color: Color(0xFF1B1B1B),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.all(8).copyWith(right: 4),
            color: const Color(0xFF262626),
            height: 110,
            width: 110,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(
                    context, RouteNames.productDetailsScreen,
                    arguments: widget.product.product.slug),
                child: CustomImage(
                  path: RemoteUrls.imageUrl(widget.product.product.thumbImage),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          //const SizedBox(width: 12),
          Flexible(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: widget.product.product.name.capitalizeByWord(),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFE5E2E1),
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // AutoSizeText(widget.product.product.name.capitalizeByWord(),
                //     textAlign: TextAlign.left,
                //     maxLines: 2,
                //     maxFontSize: 15,
                //     minFontSize: 12,
                //     overflow: TextOverflow.ellipsis,
                //     style: headlineTextStyle(15.0)),
                const SizedBox(height: 4.0),
                Row(
                  children: [
                    CustomText(
                      text: Utils.formatPrice(
                          Utils.cartProductPrice(context, widget.product),
                          context),
                      color: const Color(0xFFE2E2E2),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ),
          ),
          //const SizedBox(width: 12),
          Flexible(child: countButton(context)),
          InkWell(
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF1B1B1B),
                      insetPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                      title: Text(Language.confirmation.capitalizeByWord(),
                        style: const TextStyle(color: Color(0xFFE5E2E1)),
                      ),
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero),
                      content: const Text(
                        "Are you sure you wish to remove this item?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16.0, color: Color(0xFF919191)),
                      ),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: Text(Language.cancel.capitalizeByWord(),
                            style: const TextStyle(color: Color(0xFF919191)),
                          ),
                        ),
                        TextButton(
                            onPressed: () async {
                              final result = await context
                                  .read<CartCubit>()
                                  .removerCartItem(
                                      widget.product.id.toString());
                              widget.product;

                              result.fold(
                                (failure) {
                                  Utils.errorSnackBar(context, failure.message);
                                },
                                (success) {
                                  widget.onChange(widget.product.id);
                                  Utils.showSnackBar(context, success);
                                },
                              );
                              Navigator.of(context).pop(true);
                            },
                            child: Text(Language.delete.capitalizeByWord(),
                              style: const TextStyle(color: Color(0xFFE5E2E1)),
                            )),
                      ],
                    );
                  },
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.delete_outline_rounded,
                  size: 20,
                  color: Colors.red,
                ),
              )),
          // IconButton(
          //   onPressed: () => showDialog(
          //       context: context, builder: (context) => deleteSingleItem()),
          //   splashRadius: 20.0,
          //   icon: const CustomImage(path: KImages.deleteIcon),
          // )
        ],
      ),
    );
  }

  Widget countButton(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: Utils.toInt(widget.product.qty.toString()) > 1
              ? () async {
                  final result = await context
                      .read<CartCubit>()
                      .decrementQuantity(widget.product.id.toString());
                  result.fold((failure) {
                    Utils.errorSnackBar(context, failure.message);
                  }, (success) {
                    cartCubit.getCartProducts();
                  });
                }
              : null,
          child: Icon(
            Icons.remove_circle,
            color: const Color(0xFFE5E2E1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: CustomText(
              text: widget.product.qty.toString(),
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        InkWell(
          onTap: () async {
            final result = await context
                .read<CartCubit>()
                .incrementQuantity(widget.product.id.toString());
            result.fold((failure) {
              Utils.errorSnackBar(context, failure.message);
            }, (success) {
              cartCubit.getCartProducts();
            });
          },
          child:
              Icon(Icons.add_circle, color: const Color(0xFFE5E2E1)),
        ),
      ],
    );
  }

  // Widget deleteSingleItem() {
  //   return ClassicGeneralDialogWidget(
  //     titleText: Language.confirmation.capitalizeByWord(),
  //     contentText: "Are you sure you wish to remove this item?",
  //     onPositiveClick: () async {
  //       final result = await context
  //           .read<CartCubit>()
  //           .removerCartItem(widget.product.id.toString());
  //       widget.product;
  //
  //       result.fold(
  //         (failure) {
  //           // setState(() {});
  //           Utils.errorSnackBar(context, failure.message);
  //         },
  //         (success) {
  //           widget.onChange(widget.product.id);
  //           Utils.showSnackBar(context, success);
  //         },
  //       );
  //       Navigator.of(context).pop(true);
  //     },
  //     onNegativeClick: () => Navigator.of(context).pop(false),
  //     negativeText: Language.cancel.capitalizeByWord(),
  //     positiveText: Language.delete.capitalizeByWord(),
  //     negativeTextStyle: headlineTextStyle(16.0),
  //     positiveTextStyle: headlineTextStyle(16.0),
  //   );
  // }
}
