import 'package:flutter/material.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '/widgets/capitalized_word.dart';
import '../../core/router_name.dart';
import '../../utils/language_string.dart';
import '../../widgets/rounded_app_bar.dart';
import 'component/drawer_filter.dart';
import 'component/product_card.dart';
import 'controller/cubit/category_cubit.dart';

class SingleCategoryProductScreen extends StatefulWidget {
  const SingleCategoryProductScreen({
    super.key,
  });

  @override
  State<SingleCategoryProductScreen> createState() =>
      _SingleCategoryProductScreenState();
}

class _SingleCategoryProductScreenState
    extends State<SingleCategoryProductScreen> {
  bool _isInitialized = false;
  late String _appBarName;
  late String _keyword;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final receivedValue =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _appBarName = receivedValue['app_bar'] as String;
      _keyword = receivedValue['keyword'] as String;
      context.read<CategoryCubit>().getCategoryProduct(_keyword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF131313),
        endDrawer: const DrawerFilter(),
        appBar: RoundedAppBar(
          actions: const [SizedBox()],
          titleText: _isInitialized ? _appBarName.capitalizeByWord() : '',
          onTap: () {
            Navigator.popAndPushNamed(
                context, RouteNames.allCategoryListScreen, arguments: {'app_bar': 'Categories'});
          },
        ),
        body: BlocBuilder<CategoryCubit, CategoryState>(
          buildWhen: (previous, current) {
            return current is CategoryLoadingState ||
                current is CategoryLoadedState ||
                current is CategoryErrorState;
          },
          builder: (context, state) {
            if (state is CategoryLoadedState) {
              if (state.categoryProducts.isEmpty) {
                return Center(
                    child: Text(Language.noItemsFound.capitalizeByWord(),
                      style: GoogleFonts.manrope(color: const Color(0xFF919191)),
                    ));
              }
              return const CategoryLoad();
            } else if (state is CategoryErrorState) {
              return Center(
                child: Text(state.errorMessage),
              );
            }
            // Loading state or any other state — show loading indicator
            return const Center(
              child: SizedBox(
                height: 28,
                width: 120,
                child: ShimmerLoader.rect(height: 12, width: 120)));
          },
        ));
  }
}

class CategoryLoad extends StatelessWidget {
  const CategoryLoad({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final categoryProduct = context.read<CategoryCubit>().categoryProducts;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        sliver: MultiSliver(
          children: [
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // const SizedBox(),
                  GestureDetector(
                    onTap: () => Scaffold.of(context).openEndDrawer(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E2E1),
                      ),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                              .copyWith(bottom: 6),
                      child: Text(
                        Language.filter.capitalizeByWord(),
                        style: GoogleFonts.inter(color: const Color(0xFF131313), fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 304.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ProductCard(productModel: categoryProduct[index]);
                },
                childCount: categoryProduct.length,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
