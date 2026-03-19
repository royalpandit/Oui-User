import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/profile/model/user_info/user_updated_info.dart';
import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../main_page/main_controller.dart';

class ProfileAppBar extends StatelessWidget {
  final double height;
  final String logo;
  final UserProfileInfo userUpdateInfo;

  const ProfileAppBar({super.key, this.height = 240, required this.userUpdateInfo, required this.logo});

  @override
  Widget build(BuildContext context) {
    void gotoNext(String route) => Navigator.pushNamed(context, route);
    
    final List<Map<String, dynamic>> headerItem = [
      {"icon": Icons.receipt_long_outlined, "title": "Orders", "on_tap": () => MainController().naveListener.sink.add(1)},
      {"icon": Icons.shopping_bag_outlined, "title": "Cart", "on_tap": () => gotoNext(RouteNames.cartScreen)},
      {"icon": Icons.local_offer_outlined, "title": "Offers", "on_tap": () => gotoNext(RouteNames.flashScreen)},
      {"icon": Icons.favorite_outline, "title": "Wishlist", "on_tap": () => gotoNext(RouteNames.wishlistOfferScreen)},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _buildUserHeader(context),
            const SizedBox(height: 16),
            _buildQuickActions(headerItem),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    final userImage = userUpdateInfo.updateUserInfo!.image;
    final imagePath = userImage.isNotEmpty
        ? userImage
        : (userUpdateInfo.defaultImage?.image ?? '');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24, width: 1),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.grey.shade900,
              backgroundImage: imagePath.isNotEmpty
                  ? NetworkImage(RemoteUrls.imageUrl(imagePath))
                  : null,
              onBackgroundImageError: imagePath.isNotEmpty
                  ? (_, __) {}
                  : null,
              child: imagePath.isEmpty
                  ? const Icon(Icons.person, color: Colors.white54, size: 32)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userUpdateInfo.updateUserInfo!.name,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, RouteNames.profileEditScreen),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "EDIT PROFILE",
                      style: GoogleFonts.inter(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
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

  Widget _buildQuickActions(List<Map<String, dynamic>> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) => _actionItem(item)).toList(),
      ),
    );
  }

  Widget _actionItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: item['on_tap'],
      child: Column(
        children: [
          Icon(item['icon'], color: Colors.white70, size: 24),
          const SizedBox(height: 6),
          Text(
            item['title'],
            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}