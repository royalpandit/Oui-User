import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router_name.dart';
import '../../../utils/k_images.dart';
import '../../cart/controllers/cart/cart_cubit.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String logo;

  const HomeAppBar({super.key, this.height = 80, required this.logo});

  @override
  Widget build(BuildContext context) {
    final cartProducts = context.read<CartCubit>();

    return SliverAppBar(
      toolbarHeight: 70,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF131313),
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            Text(
              'OUI',
              style: GoogleFonts.notoSerif(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 24,
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.productSearchScreen),
              icon: const Icon(
                Icons.search_rounded,
                color: Color(0xFFE2E2E2),
                size: 24,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.wishlistOfferScreen),
              icon: const Icon(
                Icons.favorite_border_rounded,
                color: Color(0xFFE2E2E2),
                size: 22,
              ),
            ),
            const SizedBox(width: 2),
            InkWell(
              onTap: () => Navigator.pushNamed(context, RouteNames.cartScreen),
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  return CartBadge(
                    count: cartProducts.cartCount.toString(),
                    iconColor: const Color(0xFFE2E2E2),
                    badgeColor: Colors.white,
                    countColor: const Color(0xFF131313),
                  );
                },
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
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
      position: badges.BadgePosition.topEnd(top: -12, end: -10),
      badgeStyle: badges.BadgeStyle(
        badgeColor: badgeColor,
        padding: const EdgeInsets.all(4),
        elevation: 0,
      ),
      badgeContent: Text(
        count ?? '0',
        style: TextStyle(
          fontSize: 10.0,
          color: countColor,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
      child: SvgPicture.asset(
        KImages.shoppingIcon,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        height: 22,
      ),
    );
  }
}