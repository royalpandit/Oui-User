import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '/widgets/favorite_button.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../utils/utils.dart';
import '../../widgets/custom_image.dart';
import 'controllers/cart/add_to_cart/add_to_cart_cubit.dart';
import 'model/add_to_cart_model.dart';
import '../../widgets/please_sign_in_widget.dart';
import '../home/component/quote_section.dart';
import '../home/model/home_quote_model.dart';
import '../profile/profile_offer/controllers/wish_list/wish_list_cubit.dart';
import '../profile/profile_offer/model/wish_list_model.dart';
import 'component/cart_item_card.dart';
import 'component/cart_skeleton_loader.dart';
import 'controllers/cart/cart_cubit.dart';
import 'model/cart_calculation_model.dart';
import 'model/cart_response_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CartCubit>().getCartProducts();
      context.read<WishListCubit>().getWishList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: BlocConsumer<CartCubit, CartState>(
          listener: (_, state) {
            if (state is CartStateDecIncrementLoading) {
              Utils.loadingDialog(context);
            } else if (state is CartDecIncState) {
              Utils.closeDialog(context);
            } else if (state is CartStateDecIncError) {
              Utils.closeDialog(context);
              Utils.errorSnackBar(context, state.message);
            } else if (state is CartStateRemove) {
              Utils.closeDialog(context);
              Utils.showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is CartStateLoading) {
              return const CartSkeletonLoader();
            } else if (state is CartStateError) {
              if (state.statusCode == 401) {
                return const PleaseSignInWidget();
              }
              return Center(
                child: Text(
                  state.message,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.red.shade300),
                ),
              );
            }
            return const _CartLoadedBody();
          },
        ),
      ),
    );
  }
}

class _CartLoadedBody extends StatefulWidget {
  const _CartLoadedBody();

  @override
  State<_CartLoadedBody> createState() => _CartLoadedBodyState();
}

class _CartLoadedBodyState extends State<_CartLoadedBody> {
  final _couponController = TextEditingController();
  late double subTotal;
  late double total;
  late String coupon;
  CartResponseModel? cartResponseModel;
  CartCalculation? cartCalculation;

  @override
  void initState() {
    super.initState();
    cartResponseModel = context.read<CartCubit>().cartResponseModel;
    _calculate();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _calculate() {
    subTotal = 0.0;
    total = 0.0;
    coupon = "";
    if (cartResponseModel == null || cartResponseModel!.cartProducts.isEmpty) {
      cartCalculation = const CartCalculation(subTotal: "0.0", coupon: "", total: "0.0");
    } else {
      for (final e in cartResponseModel!.cartProducts) {
        subTotal += Utils.cartProductPrice(context, e) * double.parse(e.qty.toString());
      }
      total = subTotal;
      context.read<CartCubit>().getCoupon();
      if (context.read<CartCubit>().couponResponseModel != null) {
        coupon = context.read<CartCubit>().couponResponseModel!.discount;
        total = total - double.parse(coupon);
      }
      cartCalculation = CartCalculation(subTotal: subTotal.toString(), coupon: coupon, total: total.toString());
      context.read<CartCubit>().saveCartCalculation(cartCalculation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        if (cartResponseModel == null) return const SizedBox();
        final items = cartResponseModel!.cartProducts;
        final appSetting = context.read<AppSettingCubit>();

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: topPadding + 56)),

                // Items count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(
                      '${items.length} ${items.length == 1 ? 'ITEM IN YOUR BAG' : 'ITEMS IN YOUR BAG'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFA0A0A0),
                        letterSpacing: 1.2,
                        height: 1.33,
                      ),
                    ),
                  ),
                ),

                // Cart items
                if (items.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 80),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.shopping_bag_outlined, size: 48, color: Color(0xFF444444)),
                            const SizedBox(height: 16),
                            Text(
                              'YOUR BAG IS EMPTY',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF737373),
                                letterSpacing: 2.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return CartItemCard(
                            product: items[index],
                            appSetting: appSetting,
                            onRemove: (int id) {
                              cartResponseModel!.cartProducts.removeWhere((e) => e.id == id);
                              setState(() => _calculate());
                            },
                            onQuantityChanged: () {
                              setState(() => _calculate());
                            },
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
                  ),

                // Divider + Coupon + Order Summary
                if (items.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Divider(height: 1, color: Color(0x1AFFFFFF)),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildCouponSection()),
                  SliverToBoxAdapter(child: _buildOrderSummary()),
                ],

                // Quote
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: const QuoteSection(quotes: HomeQuoteModel.defaults, index: 2),
                  ),
                ),

                // Wishlist products
                SliverToBoxAdapter(child: _buildWishlistSection()),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),

            // App bar
            _buildAppBar(topPadding),
          ],
        );
      },
    );
  }

  Widget _buildAppBar(double topPadding) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, topPadding + 12, 24, 12),
        decoration: const BoxDecoration(
          color: Color(0xFF131313),
          border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
            ),
            Text(
              'SHOPPING BAG',
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 2.8,
                height: 1.43,
              ),
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROMOTION CODE',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFA0A0A0),
              letterSpacing: 3.6,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: const BoxDecoration(
              border: Border.fromBorderSide(BorderSide(color: Color(0xFF444444), width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textInputAction: TextInputAction.done,
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white, letterSpacing: 1.4),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      hintText: 'ENTER CODE',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0x66444444),
                        letterSpacing: 1.4,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (_couponController.text.trim().isEmpty) return;
                    context.read<CartCubit>().applyCoupon(_couponController.text.trim());
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      'APPLY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          BlocListener<CartCubit, CartState>(
            listener: (context, state) {
              if (state is CartCouponStateLoaded) {
                setState(() => _calculate());
              } else if (state is CartCouponStateError) {
                Utils.errorSnackBar(context, state.message);
              }
            },
            child: Text(
              'Complimentary standard shipping on all orders over ₹ 50,000.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFA0A0A0),
                height: 1.63,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(40),
        color: const Color(0xFF181818),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SUBTOTAL',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0A0A0), letterSpacing: 1.2, height: 1.33,
                  ),
                ),
                Text(
                  Utils.formatPrice(subTotal, context),
                  style: GoogleFonts.manrope(
                    fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white, height: 1.43,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SHIPPING',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w400,
                    color: const Color(0xFFA0A0A0), letterSpacing: 1.2, height: 1.33,
                  ),
                ),
                Text(
                  'COMPLIMENTARY',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: Colors.white, letterSpacing: 1.2, height: 1.33,
                  ),
                ),
              ],
            ),
            if (coupon.isNotEmpty && double.tryParse(coupon) != null && double.parse(coupon) > 0) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DISCOUNT',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w400,
                      color: const Color(0xFFFFB4AB), letterSpacing: 1.2, height: 1.33,
                    ),
                  ),
                  Text(
                    '- ${Utils.formatPrice(double.parse(coupon), context)}',
                    style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFB4AB), height: 1.43,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0x0DFFFFFF), width: 1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TOTAL',
                    style: GoogleFonts.notoSerif(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: Colors.white, letterSpacing: 1.8, height: 1.56,
                    ),
                  ),
                  Text(
                    Utils.formatPrice(total, context),
                    style: GoogleFonts.notoSerif(
                      fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white, height: 1.33,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => _showCheckoutDialog(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: Colors.white,
                child: Center(
                  child: Text(
                    'CHECKOUT',
                    style: GoogleFonts.inter(
                      fontSize: 12, fontWeight: FontWeight.w700,
                      color: const Color(0xFF131313), letterSpacing: 4.8, height: 1.33,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                const SizedBox(width: 8),
                Opacity(
                  opacity: 0.4,
                  child: Text(
                    'SECURE CHECKOUT GUARANTEED',
                    style: GoogleFonts.inter(
                      fontSize: 9, fontWeight: FontWeight.w400,
                      color: Colors.white, letterSpacing: 0.9, height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1B1B1B),
        shape: const RoundedRectangleBorder(),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'READY TO CHECKOUT?',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFA0A0A0),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'What would you like to do?',
                style: GoogleFonts.notoSerif(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, RouteNames.selectDateTimeScreen);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'CONTINUE TO CHECKOUT',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF131313),
                        letterSpacing: 3.3,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.mainPage,
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF444444), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'CONTINUE SHOPPING',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 3.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWishlistSection() {
    return BlocBuilder<WishListCubit, WishListState>(
      builder: (context, state) {
        final wishlist = context.read<WishListCubit>().wishList;
        if (wishlist.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(top: 64),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FROM YOUR WISHLIST',
                      style: GoogleFonts.inter(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: const Color(0xFFA0A0A0), letterSpacing: 3.6, height: 1.33,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Items You Loved',
                      style: GoogleFonts.notoSerif(
                        fontSize: 28, fontWeight: FontWeight.w400, color: Colors.white, height: 1.14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  separatorBuilder: (_, __) => const SizedBox(width: 2),
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: wishlist.length,
                  itemBuilder: (context, index) => _buildWishlistCard(wishlist[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistCard(WishListModel item) {
    return Container(
      width: 165,
      color: const Color(0xFF1B1B1B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              color: const Color(0xFF171717),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(
                      context, RouteNames.productDetailsScreen,
                      arguments: item.slug,
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: CustomImage(
                          path: RemoteUrls.imageUrl(item.thumbImage),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 8,
                    child: FavoriteButton(productId: item.productId),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFFE2E2E2),
                    letterSpacing: 0.6,
                    height: 1.33,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Utils.formatPrice(
                    item.offerPrice > 0 ? item.offerPrice : item.price,
                    context,
                  ),
                  style: GoogleFonts.notoSerif(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    final addToCart = AddToCartModel(
                      quantity: 1,
                      productId: item.productId,
                      image: item.thumbImage,
                      slug: item.slug,
                      token: '',
                      variantItems: const {},
                    );
                    context.read<AddToCartCubit>().addToCart(addToCart);
                  },
                  child: Text(
                    'ADD TO CART',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF919191),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
