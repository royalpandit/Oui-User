import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/home/component/home_app_bar.dart';
import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../core/router_name.dart';
import '../../dummy_data/all_dummy_data.dart';
import '../../utils/utils.dart';
import '../profile/controllers/address/address_cubit.dart';
import '../profile/model/address_model.dart';
import 'component/address_card_component.dart';
import 'component/checkout_single_item.dart';
import 'component/shiping_method_list.dart';
import 'controllers/cart/cart_cubit.dart';
import 'controllers/checkout/checkout_cubit.dart';
import 'controllers/shipping_charges/shipping_charges_cubit.dart';
import 'model/cart_calculation_model.dart';
import 'model/checkout_response_model.dart';
import 'model/shipping_response_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  CartCalculation? cartCalculation;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (context.read<CartCubit>().couponResponseModel != null) {
        context.read<CheckoutCubit>().getCheckOutData(
            context.read<CartCubit>().couponResponseModel!.code);
      } else {
        context.read<CheckoutCubit>().getCheckOutData("");
      }
      context.read<AddressCubit>().getAddress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressCubit = context.read<AddressCubit>();
    if (addressCubit.address == null) {
      log('address re-loaded');
      addressCubit.getAddress();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Language.checkout.capitalizeByWord(),
          style: GoogleFonts.inter(
              fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: (_, state) {
          if (state is CheckoutStateError) {
            Utils.errorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is CheckoutStateLoading || state is CheckoutStateInitial) {
            return const Center(
                child: CircularProgressIndicator(
                    color: Colors.black, strokeWidth: 2));
          } else if (state is CheckoutStateError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.inter(fontSize: 14, color: Colors.red),
              ),
            );
          }
          return const _LoadedWidget();
        },
      ),
    );
  }
}

class _LoadedWidget extends StatefulWidget {
  const _LoadedWidget();

  @override
  State<_LoadedWidget> createState() => _LoadedWidgetState();
}

class _LoadedWidgetState extends State<_LoadedWidget> {
  final double height = 140;
  String addressTypeSelect = Language.billingAddress.capitalizeByWord();

  final headerStyle =
      GoogleFonts.inter(fontSize: 18.0, fontWeight: FontWeight.w600);

  CheckoutResponseModel? checkoutResponseModel;
  CartCalculation? cartCalculation;
  PageController pageController =
      PageController(initialPage: 0, keepPage: true, viewportFraction: 1);
  final body = <String, dynamic>{};
  final shippingMethodList = <ShippingResponseModel>[];

  @override
  void initState() {
    super.initState();
    load();
    if (context.read<CartCubit>().couponResponseModel != null) {
      body['coupon'] = context.read<CartCubit>().couponResponseModel!.code;
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  load() {
    checkoutResponseModel = context.read<CheckoutCubit>().checkoutResponseModel;
    cartCalculation = context.read<CartCubit>().getCartCalculation();

    if (checkoutResponseModel == null) {
      return const SizedBox();
    }
    previousPrice = double.parse(cartCalculation!.total);
  }

  int shippingMethod = 0;
  int agreeTermsCondition = 1;
  int billingAddressId = 0;
  int shippingAddressId = 0;
  double totalPrice = 0.0;
  double previousPrice = 0.0;

  String basedOnWeight = 'base_on_weight';
  String basedOnPrice = 'base_on_price';
  String basedOnQty = 'base_on_qty';

  @override
  Widget build(BuildContext context) {
    context.read<ShippingChargesCubit>().getShippingCharge(previousPrice);
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildProductNumber()),
              _buildProductList(),
              SliverToBoxAdapter(child: _buildLocation()),
              if (shippingMethodList.isNotEmpty)
                SliverToBoxAdapter(
                  child: ShippingMethodList(
                    shippingMethods: shippingMethodList,
                    onChange: (int id) {
                      shippingMethod = id;
                      for (var i in shippingMethodList) {
                        if (i.id == id) {
                          totalPrice = previousPrice + i.shippingFee;
                          context
                              .read<ShippingChargesCubit>()
                              .getShippingCharge(totalPrice);
                        }
                      }
                    },
                  ),
                ),
              // SliverToBoxAdapter(child: _buildPaymentList(context)),
              SliverToBoxAdapter(
                child: CheckboxListTile(
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    Language.agreeTermAndCondition.capitalizeByWord(),
                    style:
                        GoogleFonts.inter(fontSize: 14, color: Colors.black87),
                  ),
                  value: agreeTermsCondition == 1 ? true : false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  activeColor: Colors.black,
                  onChanged: (v) {
                    if (v != null) {
                      agreeTermsCondition = agreeTermsCondition == 1 ? 0 : 1;
                      setState(() {});
                    }
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
            ],
          ),
        ),
        _bottomBtn(),
      ],
    );
  }

  Widget _bottomBtn() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BlocBuilder<ShippingChargesCubit, ShippingChargesState>(
                  builder: (context, state) {
                    if (state is ShippingChargesInitial) {
                      return const Text('');
                    } else if (state is ShippingChargesAddedState) {
                      final value =
                          context.read<ShippingChargesCubit>().initialPrice;
                      return Text(
                        "${Language.total.capitalizeByWord()}: ${Utils.formatPrice(value, context)}",
                        style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black),
                      );
                    }
                    return const SizedBox();
                  },
                ),
                Text(
                  "+${Language.shippingCost.capitalizeByWord()}",
                  style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: ElevatedButton(
              onPressed: () {
                log('Place Order: billingId=$billingAddressId, shippingId=$shippingAddressId, shippingMethod=$shippingMethod, methodListLen=${shippingMethodList.length}');
                if (agreeTermsCondition != 1) {
                  Utils.errorSnackBar(context,
                      Language.agreeTermAndCondition.capitalizeByWord());
                  return;
                } else if (billingAddressId < 1 && shippingAddressId < 1) {
                  Utils.errorSnackBar(context,
                      'Please select both billing and shipping address');
                } else if (billingAddressId < 1) {
                  Utils.errorSnackBar(
                      context, 'Please select a billing address');
                } else if (shippingAddressId < 1) {
                  Utils.errorSnackBar(
                      context, 'Please select a shipping address');
                } else if (shippingMethodList.isNotEmpty &&
                    shippingMethod < 1) {
                  Utils.errorSnackBar(
                      context, 'Please select a shipping method');
                } else {
                  body['shipping_address_id'] = shippingAddressId.toString();
                  body['billing_address_id'] = billingAddressId.toString();
                  body['shipping_method_id'] = shippingMethod.toString();
                  Navigator.pushNamed(context, RouteNames.placeOrderScreen,
                      arguments: body);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                Language.placeOrderNow.capitalizeByWord(),
                style: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocation() {
    final addressCubit = context.read<AddressCubit>();
    return Column(
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Language.deliveryLocation.capitalizeByWord(),
                  style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black)),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, RouteNames.addressScreen);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(Language.add.capitalizeByWord(),
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        BlocConsumer<AddressCubit, AddressState>(
          listener: (context, state) {
            if (state is AddressStateLoaded &&
                state.address.addresses.isNotEmpty) {
              final addresses = state.address.addresses;
              if (billingAddressId == 0) {
                billingAddressId = addresses.first.id;
              }
              if (shippingAddressId == 0) {
                shippingAddressId = addresses.first.id;
                _populateShippingMethods(addresses.first);
              }
              setState(() {});
            }
          },
          builder: (context, state) {
            if (state is AddressStateLoading) {
              return Text(Language.loading.capitalizeByWord(),
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.grey));
            } else if (state is AddressStateError) {
              return Text(state.message,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.red));
            } else if (state is AddressStateLoaded) {
              if (state.address.addresses.isEmpty) {
                return Text(Language.noAddress.capitalizeByWord(),
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey));
              } else {
                return singleAddressCard(context, state.address.addresses);
              }
            }
            if (addressCubit.address != null &&
                addressCubit.address!.addresses.isNotEmpty) {
              return singleAddressCard(
                  context, addressCubit.address!.addresses);
            }
            return const SizedBox();
          },
        )
      ],
    );
  }

  Widget singleAddressCard(BuildContext context, List<AddressModel> address) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              ...addressType.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          setState(() {
                            addressTypeSelect = e.value;
                            pageController.animateToPage(e.key,
                                duration: const Duration(microseconds: 500),
                                curve: Curves.ease);
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(microseconds: 300),
                          curve: Curves.ease,
                          decoration: BoxDecoration(
                              color: addressTypeSelect == e.value
                                  ? Colors.black
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          child: Text(
                            e.value,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: addressTypeSelect == e.value
                                  ? Colors.white
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.24,
          child: PageView.builder(
            itemCount: addressType.length,
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                padding: const EdgeInsets.only(left: 20),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ...List.generate(
                      address.length,
                      (index) => shippingCharges(address, index),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

  void _populateShippingMethods(AddressModel selectedAddress) {
    if (checkoutResponseModel == null) return;
    shippingMethodList.clear();
    shippingMethodList.addAll(checkoutResponseModel!.shippings
        .where((element) => element.cityId == 0)
        .toList());
    shippingMethodList.addAll(checkoutResponseModel!.shippings
        .where((element) => element.cityId == selectedAddress.cityId)
        .toList());
    // Auto-select first shipping method
    if (shippingMethodList.isNotEmpty) {
      shippingMethod = shippingMethodList.first.id;
      totalPrice = previousPrice + shippingMethodList.first.shippingFee;
    }
  }

  Widget shippingCharges(List<AddressModel> address, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          if (addressTypeSelect == Language.billingAddress.capitalizeByWord()) {
            billingAddressId = address[index].id;
          } else {
            _populateShippingMethods(address[index]);

            // for (var shipping in checkoutResponseModel!.shippings) {
            //   if (shipping.type == basedOnPrice) {
            //     if (shipping.conditionFrom <= previousPrice &&
            //         shipping.conditionTo >= previousPrice) {
            //       print('addressId $shippingAddressId');
            //       print('shippingId ${shipping.id}');
            //       if (shippingAddressId != shipping.id) {
            //         shippingMethodList.add(shipping);
            //       }
            //     }
            //   }
            //
            //   if (shipping.type == basedOnWeight) {
            //     if (shipping.conditionFrom <= previousPrice &&
            //         shipping.conditionTo >= previousPrice) {
            //       shippingMethodList.add(shipping);
            //       // if (shippingAddressId != shipping.id) {
            //       //   shippingMethodList.add(shipping);
            //       // }
            //     }
            //   }
            //
            //   if (shipping.type == basedOnQty) {
            //     if (shipping.conditionFrom <= previousPrice &&
            //         shipping.conditionTo >= previousPrice) {
            //       shippingMethodList.add(shipping);
            //     }
            //   }

            //shippingAddressId = state.address.addresses[index].id;
            //setState(() {});
            //}

            shippingAddressId = address[index].id;
          }
          setState(() {});
        },
        child: AddressCardComponent(
            isEditButtonShow: false,
            selectAddress:
                addressTypeSelect == Language.billingAddress.capitalizeByWord()
                    ? billingAddressId
                    : shippingAddressId,
            addressModel: address[index],
            type: address[index].type),
      ),
    );
  }

  Widget _buildProductList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return CheckoutSingleItem(
              product: checkoutResponseModel!.cartProducts[index],
            );
          },
          childCount: checkoutResponseModel!.cartProducts.length,
          addAutomaticKeepAlives: true,
        ),
      ),
    );
  }

  Widget _buildProductNumber() {
    String totalProduct = checkoutResponseModel!.cartProducts.length.toString();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Row(
        children: [
          CartBadge(
              count: totalProduct,
              badgeColor: Colors.black,
              iconColor: Colors.white),
          const SizedBox(width: 20),
          Text(
            "$totalProduct ${Language.products.capitalizeByWord()}",
            style: GoogleFonts.inter(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
