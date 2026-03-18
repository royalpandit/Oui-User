import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/utils/language_string.dart';
import 'package:shop_us/widgets/capitalized_word.dart';

import '../../../core/router_name.dart';
import '../../../utils/k_images.dart';
import '../../cart/controllers/cart/cart_cubit.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String logo;

  const HomeAppBar({super.key, this.height = 160, required this.logo});

  @override
  Widget build(BuildContext context) {
    final cartProducts = context.read<CartCubit>();
    return SliverAppBar(
      toolbarHeight: 140.0,
      pinned: true,
      backgroundColor: Colors.black,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16.0),
          Row(
            children: [
              Text(
                'OUI',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () =>
                    Navigator.pushNamed(context, RouteNames.cartScreen),
                child: BlocBuilder<CartCubit, CartState>(
                  builder: (context, state) {
                    return CartBadge(
                      count: cartProducts.cartCount.toString(),
                      iconColor: Colors.white,
                      badgeColor: Colors.white,
                      countColor: Colors.black,
                    );
                  },
                ),
              ),
              const SizedBox(width: 12.0),
            ],
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, RouteNames.productSearchScreen),
            child: Container(
              margin: const EdgeInsets.only(top: 16.0),
              padding:
                  const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.white70, size: 20.0),
                  const SizedBox(width: 10.0),
                  Text(
                    Language.searchProduct.capitalizeByWord(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(124.0);
}

class CartBadge extends StatelessWidget {
  const CartBadge({
    super.key,
    required this.count,
    this.iconColor = Colors.white,
    this.badgeColor = Colors.black,
    this.countColor = Colors.white,
  });

  final String? count;
  final Color iconColor;
  final Color badgeColor;
  final Color countColor;

  @override
  Widget build(BuildContext context) {
    return badges.Badge(
      badgeStyle: badges.BadgeStyle(
        badgeColor: badgeColor,
      ),
      badgeContent: Text(
        count!,
        style: TextStyle(fontSize: 12.0, color: countColor, height: 1.5),
      ),
      child: SvgPicture.asset(KImages.shoppingIcon, color: iconColor),
    );
  }
}

