import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../core/router_name.dart';
import '../model/home_seller_model.dart';
import 'section_header.dart';
import 'single_circuler_seller.dart';

class BestSellerGridView extends StatelessWidget {
  const BestSellerGridView({
    super.key,
    required this.sellers,
    required this.sectionTitle,
  });

  final List<HomeSellerModel> sellers;
  final String sectionTitle;

  @override
  Widget build(BuildContext context) {
    if (sellers.isEmpty) return const SliverToBoxAdapter();

    String formattedTitle = sectionTitle.split(' ').map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');

    return SliverPadding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      sliver: MultiSliver(
        children: [
          SliverToBoxAdapter(
            child: SectionHeader(
              headerText: formattedTitle,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RouteNames.allSellerList,
                  arguments: sellers,
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 105,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: sellers.length > 8 ? 8 : sellers.length,
                itemBuilder: (context, index) {
                  return SingleCircularSeller(seller: sellers[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}