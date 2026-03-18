import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../core/router_name.dart';
import '../../category/component/single_circuler_card.dart';
import '../model/home_categories_model.dart';
import 'section_header.dart';

class CategoryGridView extends StatelessWidget {
  const CategoryGridView({
    Key? key,
    required this.homeCategories,
    required this.sectionTitle,
  }) : super(key: key);
  final List<HomePageCategoriesModel> homeCategories;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    if (homeCategories.isEmpty) return const SliverToBoxAdapter();
    return SliverPadding(
      padding: const EdgeInsets.only(left: 0, right: 0, top: 16, bottom: 8),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: SectionHeader(
              // headerText: 'Market Categories',
              headerText: sectionTitle,
              color: Colors.black,
              onTap: () {
                Navigator.pushNamed(context, RouteNames.allCategoryListScreen,
                    arguments: {
                      'app_bar': sectionTitle,
                    });
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...List.generate(
                    homeCategories.length > 6 ? 6 : homeCategories.length,
                    (index) => Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: CategoryCircleCard(
                        homeCategories: homeCategories[index],
                      ),
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
}
