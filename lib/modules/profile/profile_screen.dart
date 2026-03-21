import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/profile/controllers/updated_info/updated_info_cubit.dart';
import '/utils/language_string.dart';
import '/utils/utils.dart';
import '/widgets/capitalized_word.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../widgets/custom_image.dart';
import '../../widgets/please_sign_in_widget.dart';
import '../authentication/controller/login/login_bloc.dart';
import '../home/controller/cubit/home_controller_cubit.dart';
import '../home/model/product_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = context.read<LoginBloc>().userInfo;

    if (userData == null) {
      return const PleaseSignInWidget();
    }

    // Get recommended products
    List<ProductModel> recommended = [];
    try {
      final homeState = context.read<HomeControllerCubit>().state;
      if (homeState is HomeControllerLoaded) {
        recommended = context.read<HomeControllerCubit>().homeModel.topRatedProducts;
      }
    } catch (_) {}



    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Top spacing for app bar
              const SliverToBoxAdapter(child: SizedBox(height: 96)),

              // ── Avatar + Name + Member badge ──
              SliverToBoxAdapter(
                child: BlocBuilder<UserProfileInfoCubit, UserProfilenfoState>(
                  builder: (context, state) {
                    String name = userData.user.name;
                    String image = '';
                    if (state is UpdatedLoaded) {
                      name = state.updatedInfo.updateUserInfo?.name ?? name;
                      image = state.updatedInfo.updateUserInfo?.image ?? '';
                    }
                    return _buildProfileHeader(name, image);
                  },
                ),
              ),

              // ── RECOMMENDED Section ──
              if (recommended.isNotEmpty)
                SliverToBoxAdapter(child: _buildRecommended(recommended)),

              // ── ACTIVITY Section ──
              SliverToBoxAdapter(child: _buildActivitySection(context)),

              // ── MANAGEMENT Section (hidden) ──
              // SliverToBoxAdapter(child: _buildManagementSection(context)),

              // ── CONCIERGE & LEGAL Section ──
              SliverToBoxAdapter(child: _buildLegalSection(context)),

              // ── Sign out button ──
              SliverToBoxAdapter(child: _buildSignOutButton(context)),

              // ── Footer ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 32, bottom: 100),
                  child: Center(
                    child: Text(
                      "OUI The Premium Store \u00a9 2026",
                      style: GoogleFonts.inter(
                        fontSize: 9, fontWeight: FontWeight.w400,
                        color: const Color(0xFF5E5E5E),
                        height: 1.5, letterSpacing: 4.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── App bar overlay ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 64,
              padding: const EdgeInsets.only(left: 24, right: 24),
              decoration: const BoxDecoration(
                color: Color(0xE5131313),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Spacer(),
                    Text(
                      'PROFILE',
                      style: GoogleFonts.notoSerif(
                        fontSize: 18, fontWeight: FontWeight.w400,
                        color: Colors.white, height: 1.56,
                        letterSpacing: 1.8,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, RouteNames.profileEditScreen),
                      child: Text(
                        'EDIT',
                        style: GoogleFonts.notoSerif(
                          fontSize: 14, fontWeight: FontWeight.w400,
                          color: Colors.white, height: 1.43,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String image) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96, height: 96,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Color(0xFF262626)),
            child: image.isNotEmpty
                ? CustomImage(path: RemoteUrls.imageUrl(image), fit: BoxFit.cover)
                : Container(color: const Color(0xFF1C1B1B)),
          ),
          const SizedBox(height: 24),
          // Name
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 30, fontWeight: FontWeight.w400,
              color: const Color(0xFFE5E2E1), height: 1.2,
              letterSpacing: -0.75,
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildRecommended(List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.only(top: 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RECOMMENDED',
                  style: GoogleFonts.notoSerif(
                    fontSize: 20, fontWeight: FontWeight.w400,
                    color: const Color(0xFFE5E2E1), height: 1.4,
                    letterSpacing: 2,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, RouteNames.allCategoryListScreen, arguments: {
                      'app_bar': 'Categories',
                    });
                  },
                  child: Text(
                    'VIEW ALL',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: const Color(0xFF777777), height: 1.5,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 392,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: products.length > 10 ? 10 : products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 24),
              itemBuilder: (_, index) => _buildProductCard(products[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, RouteNames.productDetailsScreen,
        arguments: product.slug,
      ),
      child: SizedBox(
        width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 240,
              height: 320,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFF1C1B1B)),
              child: CustomImage(
                path: RemoteUrls.imageUrl(product.thumbImage),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSerif(
                fontSize: 14, fontWeight: FontWeight.w400,
                color: const Color(0xFFE5E2E1), height: 1.43,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Utils.formatPrice(
                product.offerPrice > 0 ? product.offerPrice : product.price,
                context,
              ),
              style: GoogleFonts.inter(
                fontSize: 12, fontWeight: FontWeight.w400,
                color: const Color(0xFF777777), height: 1.33,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label
          Text(
            'ACTIVITY',
            style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w400,
              color: const Color(0xFF777777), height: 1.5,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          _buildActivityRow(
            icon: Icons.shopping_bag_outlined,
            title: 'My Orders',
            onTap: () => Navigator.pushNamed(context, RouteNames.orderScreen),
          ),
          _buildActivityRow(
            icon: Icons.shopping_cart_outlined,
            title: 'Shopping Bag',
            onTap: () => Navigator.pushNamed(context, RouteNames.cartScreen),
          ),
          _buildActivityRow(
            icon: Icons.local_offer_outlined,
            title: 'Offers',
            onTap: () => Navigator.pushNamed(context, RouteNames.flashScreen),
          ),
          _buildActivityRow(
            icon: Icons.favorite_border,
            title: 'Wishlist',
            onTap: () => Navigator.pushNamed(context, RouteNames.wishlistOfferScreen),
          ),
          _buildActivityRow(
            icon: Icons.location_on_outlined,
            title: 'Address',
            onTap: () => Navigator.pushNamed(context, RouteNames.addressScreen),
          ),
          _buildActivityRow(
            icon: Icons.category_outlined,
            title: 'Categories',
            onTap: () => Navigator.pushNamed(context, RouteNames.allCategoryListScreen, arguments: {'app_bar': 'Categories'}),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 61,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1, color: Color(0x19434842)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFFE5E2E1)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w400,
                  color: const Color(0xFFE5E2E1), height: 1.43,
                  letterSpacing: 0.35,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF5E5E5E)),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: Color(0xFFF3F3F3)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MANAGEMENT',
              style: GoogleFonts.inter(
                fontSize: 10, fontWeight: FontWeight.w400,
                color: const Color(0xFF777777), height: 1.5,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 32),

            // Primary Location
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, RouteNames.addressScreen),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRIMARY LOCATION',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: const Color(0xFF5E5E5E), height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage your addresses',
                    style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w400,
                      color: const Color(0xFF1B1B1B), height: 1.43,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Color(0x4CC6C6C6)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SAVED CATEGORIES',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: const Color(0xFF5E5E5E), height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildCategoryTag('OUTERWEAR'),
                      const SizedBox(width: 8),
                      _buildCategoryTag('ACCESSORIES'),
                    ],
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1, color: Color(0x4CC6C6C6)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PAYMENT',
                    style: GoogleFonts.inter(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: const Color(0xFF5E5E5E), height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'COD / Online Payment',
                    style: GoogleFonts.manrope(
                      fontSize: 14, fontWeight: FontWeight.w400,
                      color: const Color(0xFF1B1B1B), height: 1.43,
                      letterSpacing: -0.7,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: const BoxDecoration(color: Color(0xFFF9F9F9)),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10, fontWeight: FontWeight.w400,
          color: const Color(0xFF1B1B1B), height: 1.5,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CONCIERGE & LEGAL',
            style: GoogleFonts.inter(
              fontSize: 10, fontWeight: FontWeight.w400,
              color: const Color(0xFF777777), height: 1.5,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 24),
          _buildActivityRow(
            icon: Icons.description_outlined,
            title: 'Terms and Conditions',
            onTap: () => Navigator.pushNamed(context, RouteNames.termsConditionScreen),
          ),
          _buildActivityRow(
            icon: Icons.shield_outlined,
            title: 'Privacy Policy',
            onTap: () => Navigator.pushNamed(context, RouteNames.privacyPolicyScreen),
          ),
          _buildActivityRow(
            icon: Icons.help_outline,
            title: 'FAQ',
            onTap: () => Navigator.pushNamed(context, RouteNames.faqScreen),
          ),
          _buildActivityRow(
            icon: Icons.info_outline,
            title: 'About OUI',
            onTap: () => Navigator.pushNamed(context, RouteNames.aboutUsScreen),
          ),
          _buildActivityRow(
            icon: Icons.mail_outline,
            title: 'Contact Curator',
            onTap: () => Navigator.pushNamed(context, RouteNames.contactUsScreen),
          ),
          _buildActivityRow(
            icon: Icons.phone_android_outlined,
            title: 'App Info',
            onTap: () => _showAppInfoSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
      child: BlocConsumer<LoginBloc, LoginModelState>(
        listener: (context, state) {
          final logout = state.state;
          if (logout is LoginStateLogOutLoading) {
            Utils.loadingDialog(context);
          } else {
            Utils.closeDialog(context);
            if (logout is LoginStateSignOutError) {
              Utils.errorSnackBar(context, logout.errorMsg);
            } else if (logout is LoginStateLogOut) {
              Navigator.pushNamedAndRemoveUntil(context, RouteNames.authenticationScreen, (route) => false);
            }
          }
        },
        builder: (context, state) {
          return GestureDetector(
            onTap: () => _showLogoutDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(color: const Color(0xFFE5E2E1)),
              child: Center(
                child: Text(
                  'SIGN OUT',
                  style: GoogleFonts.inter(
                    fontSize: 12, fontWeight: FontWeight.w400,
                    color: const Color(0xFF131313), height: 1.33,
                    letterSpacing: 4.8,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAppInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, color: const Color(0xFF444444)),
                const SizedBox(height: 24),
                Text(
                  Language.appInfo.capitalizeByWord(),
                  style: GoogleFonts.notoSerif(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white),
                ),
                const SizedBox(height: 20),
                _infoRow(Language.name.capitalizeByWord(), "OUI"),
                _infoRow(Language.version.capitalizeByWord(), "1.3.0"),
                _infoRow("Build", "1"),
                _infoRow("Platform", "Android / iOS"),
                _infoRow(Language.developedBy.capitalizeByWord(), "Corescent"),
                const SizedBox(height: 20),
                Text(
                  "OUI is a premium shopping experience designed to bring the finest selection of products right to your doorstep.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF777777), height: 1.5),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF777777))),
          Text(value, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE2E2E2))),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        surfaceTintColor: const Color(0xFF1A1A1A),
        shape: const RoundedRectangleBorder(),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF262626),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, size: 32, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text("Sign Out", style: GoogleFonts.notoSerif(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              "Are you sure you want to end your session?",
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF777777)),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF444444)),
                    ),
                    child: Center(
                      child: Text("Cancel", style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    context.read<LoginBloc>().add(const LoginEventLogout());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: Colors.white,
                    child: Center(
                      child: Text("Logout", style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: Colors.black)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}