import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/utils/language_string.dart';
import 'package:shop_us/widgets/capitalized_word.dart';

import '/modules/cart/model/cart_calculation_model.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../controllers/cart/cart_cubit.dart';
import '../model/cart_response_model.dart';

class PanelCollaspComponent extends StatelessWidget {
  const PanelCollaspComponent(
      {super.key,
      required this.height,
      required this.cartResponseModel,
      required this.totalPrice});

  final CartResponseModel cartResponseModel;
  final double height;
  final double totalPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
            height: 4,
            width: 60,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.orderAmount.capitalizeByWord(),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
              ),
              Text(
                Utils.formatPriceIcon(totalPrice.toString(), context),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.selectDateTimeScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Select Date & Time',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PanelComponent extends StatefulWidget {
  const PanelComponent({
    super.key,
    this.controller,
    required this.cartResponseModel,
    required this.cartCalculation,
  });

  final CartResponseModel cartResponseModel;

  final ScrollController? controller;
  final CartCalculation? cartCalculation;

  @override
  State<PanelComponent> createState() => _PanelComponentState();
}

class _PanelComponentState extends State<PanelComponent> {
  final textController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.read<CartCubit>().couponResponseModel;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )),
      child: ListView(
        controller: widget.controller,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: [
          Text(Language.applyCoupon.capitalizeByWord(),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 7),
          _buildTextField(),
          const SizedBox(height: 8),
          Text(
            Language.billDetails.capitalizeByWord(),
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.subTotal.capitalizeByWord(),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
              ),
              Text(
                Utils.formatPriceIcon(
                    widget.cartCalculation!.subTotal, context),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.discountCoupon.capitalizeByWord(),
                style: GoogleFonts.inter(fontSize: 14, color: Colors.red),
              ),
              BlocConsumer<CartCubit, CartState>(listener: (context, state) {
                if (state is CartCouponStateLoading) {
                  Utils.loadingDialog(context);
                } else {
                  Utils.closeDialog(context);
                  if (state is CartCouponStateError) {
                    Utils.errorSnackBar(context, state.message);
                  }
                }
              }, builder: (context, state) {
                if (state is CartCouponStateError) {
                  return Text(state.message);
                }
                if (state is CartCouponStateLoaded) {
                  double total = double.parse(widget.cartCalculation!.total);
                  double coupon =
                      double.parse(state.couponResponseModel.discount);
                  final maxPrice =
                      double.parse(state.couponResponseModel.minPurchasePrice);
                  if (total >= maxPrice) {
                    widget.cartCalculation!
                        .copyWith(total: (total - coupon).toString());
                  }

                  return Text(
                      Utils.formatPriceIcon(
                          state.couponResponseModel.discount, context),
                      style: GoogleFonts.inter(fontSize: 14, color: Colors.red));
                }
                return const SizedBox();
              }),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Language.orderAmount.capitalizeByWord(),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              ),
              Text(
                Utils.formatPriceIcon(widget.cartCalculation!.total, context),
                style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black),
              )
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.selectDateTimeScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Select Date & Time',
                style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: textController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: Language.promoCode.capitalizeByWord(),
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                fillColor: Colors.transparent,
                filled: true,
              ),
              style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (textController.text.isEmpty) {
                return;
              }
              else {
                context
                    .read<CartCubit>()
                    .applyCoupon(textController.text.trim());
              }
              setState(() {});
            },
            child: Container(
              height: 50,
              width: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(Language.apply.capitalizeByWord(),
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
