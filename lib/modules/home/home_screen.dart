import 'dart:developer';
import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router_name.dart';
import '../../utils/notifications.dart';
import '../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../cart/controllers/cart/add_to_cart/add_to_cart_cubit.dart';
import '../cart/controllers/cart/cart_cubit.dart';
import 'component/best_seller_grid_view.dart';
import 'component/category_and_list_component.dart';
import 'component/category_grid_view.dart';
import 'component/flash_sale_component.dart';
import 'component/home_app_bar.dart';
import 'component/hot_deal_banner_slider.dart';
import 'component/new_arrival_component.dart';
import 'component/offer_banner_slider.dart';
import 'component/auto_scroll_product_strip.dart';
import 'component/featured_highlight_card.dart';
import 'component/populer_product_component.dart';
import 'component/quote_section.dart';
import 'controller/cubit/home_controller_cubit.dart';
import 'model/banner_model.dart';
import 'model/home_model.dart';
import 'model/product_model.dart';

/// Checks dynamic visibility flag (handles bool, int, String from API)
bool _isVisible(dynamic flag) {
  if (flag == true || flag == 1 || flag == '1') return true;
  return false;
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const _className = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddToCartCubit, AddToCartState>(
      listenWhen: (previous, current) => true,
      listener: (context, state) {
        if (state is AddToCartStateAdded) {
          context.read<CartCubit>().getCartProducts();
          showBottomPopup(context, message: state.message, success: true);
        } else if (state is AddToCartStateError) {
          showBottomPopup(context, message: state.message, success: false);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: const Color(0xFF131313),
          body: BlocBuilder<HomeControllerCubit, HomeControllerState>(
            builder: (context, state) {
              log(state.toString(), name: _className);
              if (state is HomeControllerLoading) {
                return const _HomeSkeletonLoader();
              }
              if (state is HomeControllerError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.errorMessage,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF919191),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Semantics(
                        button: true,
                        label: 'Retry loading home page',
                        child: IconButton(
                          onPressed: () {
                            context.read<HomeControllerCubit>().getHomeData();
                          },
                          icon: const Icon(
                            Icons.refresh_outlined,
                            color: Color(0xFFE2E2E2),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is HomeControllerLoaded) {
                return _LoadedHomePage(homeModel: state.homeModel);
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}

class _LoadedHomePage extends StatelessWidget {
  const _LoadedHomePage({
    required this.homeModel,
  });

  final HomeModel homeModel;

  @override
  Widget build(BuildContext context) {
    final combineBannerList = _buildCombineBanners();
    final h = homeModel;
    String st(int i) =>
        '${h.sectionTitle[i].custom ?? h.sectionTitle[i].defaultTitle}';

    return CustomScrollView(
      physics: const ClampingScrollPhysics(),
      slivers: [
        HomeAppBar(
          logo: context.read<AppSettingCubit>().settingModel!.setting!.logo,
        ),

        // Categories
        CategoryGridView(
          homeCategories: h.homeCategories,
          sectionTitle: st(0),
        ),

        // Banner slider
        if (_isVisible(h.sliderVisibilty))
          SliverToBoxAdapter(
            child: OfferBannerSlider(sliders: h.sliders),
          ),

        // Quote section 1
        if (_isVisible(h.quoteVisibility))
          SliverToBoxAdapter(
            child: QuoteSection(quotes: h.quotes, index: 0),
          ),

        // Popular products
        if (_isVisible(h.popularCategoryVisibilty))
          HorizontalProductComponent(
            productList: h.popularCategoryProducts,
            category: st(1),
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {'keyword': 'popular_category', 'app_bar': st(1)},
            ),
          ),

        // Featured highlight card (random product each build)
        if (_isVisible(h.featuredHighlightVisibility) &&
            h.featuredCategoryProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: FeaturedHighlightCard(
                product: h.featuredCategoryProducts[
                    Random().nextInt(h.featuredCategoryProducts.length)],
              ),
            ),
          ),

        // Flash sale
        SliverToBoxAdapter(
          child: FlashSaleComponent(flashSale: h.flashSale),
        ),

        // Top rated products
        if (_isVisible(h.topRatedVisibility))
          CategoryAndListComponent(
            productList: h.topRatedProducts,
            category: st(2),
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {
                'keyword': 'top_product',
                'app_bar': st(2),
                'products': h.topRatedProducts,
              },
            ),
          ),

        // Featured products
        if (_isVisible(h.featuredProductVisibility))
          HorizontalProductComponent(
            productList: h.featuredCategoryProducts,
            category: st(5),
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {'keyword': 'featured_product', 'app_bar': st(5)},
            ),
          ),

        // Best products
        if (_isVisible(h.bestProductVisibility))
          HorizontalProductComponent(
            productList: h.bestProducts,
            category: st(4),
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {'keyword': 'best_product', 'app_bar': st(4)},
            ),
          ),

        // Quote section 2
        if (_isVisible(h.quoteVisibility) && h.quotes.length > 1)
          SliverToBoxAdapter(
            child: QuoteSection(quotes: h.quotes, index: 1),
          ),

        // Auto-scroll trending strip
        if (_isVisible(h.trendingVisibility) && h.trendingProducts.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: AutoScrollProductStrip(
                products: h.trendingProducts,
                title: h.trendingSectionTitle,
                onViewAll: () => Navigator.pushNamed(
                  context,
                  RouteNames.allPopulerProductScreen,
                  arguments: {
                    'keyword': 'top_product',
                    'app_bar': h.trendingSectionTitle,
                    'products': h.trendingProducts,
                  },
                ),
              ),
            ),
          ),

        // Combined banners slider
        SliverToBoxAdapter(
          child: CombineBannerSlider(banners: combineBannerList),
        ),

        // Best sellers
        if (_isVisible(h.sellerVisibility))
          BestSellerGridView(
            sellers: h.sellers,
            sectionTitle: st(3),
          ),

        // New arrivals grid
        if (_isVisible(h.newArrivalProductVisibility))
          NewArrivalComponent(
            productList: _dedup(h.newArrivalProducts),
            sectionTitle: st(5),
            onViewAll: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {
                'keyword': 'new_arrival',
                'app_bar': st(5),
                'products': _dedup(h.newArrivalProducts),
              },
            ),
          ),

        // Quote section 3
        if (_isVisible(h.quoteVisibility) && h.quotes.length > 2)
          SliverToBoxAdapter(
            child: QuoteSection(quotes: h.quotes, index: 2),
          ),

        // "Just For You" — shuffled mix from all product lists
        if (_buildJustForYou(h).isNotEmpty)
          HorizontalProductComponent(
            productList: _buildJustForYou(h),
            category: 'Just For You',
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {
                'app_bar': 'Just For You',
                'products': _buildJustForYou(h),
              },
            ),
          ),

        // Quote section 4
        if (_isVisible(h.quoteVisibility) && h.quotes.length > 3)
          SliverToBoxAdapter(
            child: QuoteSection(quotes: h.quotes, index: 3),
          ),

        // "Editors Picks" — another curated mix
        if (_buildEditorsPicks(h).isNotEmpty)
          HorizontalProductComponent(
            productList: _buildEditorsPicks(h),
            category: 'Editor\'s Picks',
            onTap: () => Navigator.pushNamed(
              context,
              RouteNames.allPopulerProductScreen,
              arguments: {
                'app_bar': 'Editor\'s Picks',
                'products': _buildEditorsPicks(h),
              },
            ),
          ),

        // Final quote
        if (_isVisible(h.quoteVisibility) && h.quotes.length > 4)
          SliverToBoxAdapter(
            child: QuoteSection(quotes: h.quotes, index: 4),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  /// Remove duplicate products by id, keeping first occurrence.
  static List<ProductModel> _dedup(List<ProductModel> list) {
    final seen = <int>{};
    return [for (final p in list) if (seen.add(p.id)) p];
  }

  /// Shuffled mix of featured + top-rated products
  List<ProductModel> _buildJustForYou(HomeModel h) {
    final seen = <int>{};
    final list = <ProductModel>[];
    for (final p in [...h.featuredCategoryProducts, ...h.topRatedProducts]) {
      if (seen.add(p.id)) list.add(p);
    }
    list.shuffle(Random());
    return list.take(10).toList();
  }

  /// Shuffled mix of best + new arrival products
  List<ProductModel> _buildEditorsPicks(HomeModel h) {
    final seen = <int>{};
    final list = <ProductModel>[];
    for (final p in [...h.bestProducts, ...h.newArrivalProducts]) {
      if (seen.add(p.id)) list.add(p);
    }
    list.shuffle(Random());
    return list.take(10).toList();
  }

  List<BannerModel> _buildCombineBanners() {
    final rawBannerList = <BannerModel>[
      if (homeModel.sliderBannerOne != null) homeModel.sliderBannerOne!,
      if (homeModel.sliderBannerTwo != null) homeModel.sliderBannerTwo!,
      if (homeModel.twoColumnBannerOne != null) homeModel.twoColumnBannerOne!,
      if (homeModel.twoColumnBannerTwo != null) homeModel.twoColumnBannerTwo!,
    ];
    final categorySlugs = homeModel.homeCategories.map((c) => c.slug).toList();
    final result = <BannerModel>[];
    for (int i = 0; i < rawBannerList.length; i++) {
      if (i < categorySlugs.length) {
        result.add(rawBannerList[i].copyWith(
          slug: categorySlugs[i],
          titleOne: homeModel.homeCategories[i].name,
        ));
      } else {
        result.add(rawBannerList[i]);
      }
    }
    return result;
  }
}

class _HomeSkeletonLoader extends StatelessWidget {
  const _HomeSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1B1B1B),
      highlightColor: const Color(0xFF2A2A2A),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App bar placeholder
            Container(
              height: 70,
              width: double.infinity,
              color: const Color(0xFF1B1B1B),
            ),
            const SizedBox(height: 24),
            // Category circles row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  5,
                  (_) => Column(
                    children: [
                      _skBox(54, 54, 27),
                      const SizedBox(height: 8),
                      _skBox(44, 10, 4),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Banner placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _skBox(double.infinity, 180, 16),
            ),
            const SizedBox(height: 24),
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_skBox(120, 18, 4), _skBox(56, 14, 4)],
              ),
            ),
            const SizedBox(height: 14),
            // Product cards row
            SizedBox(
              height: 280,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => _skBox(160, 280, 12),
              ),
            ),
            const SizedBox(height: 24),
            // Flash sale placeholder
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _skBox(double.infinity, 140, 16),
            ),
            const SizedBox(height: 24),
            // Another section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_skBox(100, 18, 4), _skBox(56, 14, 4)],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 280,
              child: ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, __) => _skBox(160, 280, 12),
              ),
            ),
            const SizedBox(height: 24),
            // Combined banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _skBox(double.infinity, 160, 16),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  static Widget _skBox(double w, double h, double r) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: const Color(0xFF1B1B1B),
          borderRadius: BorderRadius.circular(r),
        ),
      );
}