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
      toolbarHeight: 80.0,
      pinned: true,
      elevation: 0,
      // Fix: Prevent Material 3 from changing color to blue on scroll
      backgroundColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      // Shape: Rounded bottom corners over the white body
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(24),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            // 1. Logo on the Left Side
            Image.asset(
              'assets/icon/login.png',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Text(
                'OUI',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
            ),
            const Spacer(),
            
            // 2. Search Icon (To the left of Wishlist)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.productSearchScreen),
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),

            // 3. Wishlist Icon (To the left of Cart)
            IconButton(
              onPressed: () => Navigator.pushNamed(context, RouteNames.wishlistOfferScreen),
              icon: const Icon(
                Icons.favorite_border_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),

            const SizedBox(width: 4.0),

            // 4. Cart Icon (Far Right)
            InkWell(
              onTap: () => Navigator.pushNamed(context, RouteNames.cartScreen),
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
            const SizedBox(width: 8.0),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80.0);
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
        height: 24,
      ),
    );
  }
}