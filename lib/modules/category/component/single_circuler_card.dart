import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop_us/core/remote_urls.dart';
import 'package:shop_us/modules/home/model/home_categories_model.dart';
import 'package:shop_us/widgets/capitalized_word.dart';
import 'package:shop_us/widgets/custom_image.dart';

import '../../../core/router_name.dart';

class CategoryCircleCard extends StatelessWidget {
  const CategoryCircleCard({
    super.key,
    required this.homeCategories,
  });

  final HomePageCategoriesModel homeCategories;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Category: ${homeCategories.name}',
      button: true,
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, RouteNames.singleCategoryProductScreen,
              arguments: {
                'keyword': homeCategories.slug,
                'app_bar': homeCategories.name,
              });
        },
        child: SizedBox(
        width: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1B1B1B),
                border: Border.all(color: const Color(0xFF474747), width: 1.0),
              ),
              child: ClipOval(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: CustomImage(
                    path: RemoteUrls.imageUrl(homeCategories.image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              homeCategories.name.capitalizeByWord(),
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFC7C6C6),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}