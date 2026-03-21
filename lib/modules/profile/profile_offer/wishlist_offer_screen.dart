import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../../../widgets/favorite_button.dart';
import '../../cart/controllers/cart/add_to_cart/add_to_cart_cubit.dart';
import '../../cart/model/add_to_cart_model.dart';
import '../../home/controller/cubit/home_controller_cubit.dart';
import '../../home/model/home_quote_model.dart';
import '../../home/model/product_model.dart';
import '../../product_details/model/product_variant_model.dart';
import 'controllers/wish_list/wish_list_cubit.dart';
import 'model/wish_list_model.dart';

class WishlistOfferScreen extends StatefulWidget {
  const WishlistOfferScreen({super.key});

  @override
  State<WishlistOfferScreen> createState() => _WishlistOfferScreenState();
}

class _WishlistOfferScreenState extends State<WishlistOfferScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<WishListCubit>().getWishList();
      context.read<WishListCubit>().selectedId.clear();
      context.read<WishListCubit>().wishList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: BlocConsumer<WishListCubit, WishListState>(
        listener: (context, state) {
          if (state is WishListStateAddRemoveError) {
            Utils.errorSnackBar(context, state.message);
          } else if (state is WishListStateSuccess) {
            Utils.showSnackBar(context, state.message);
          } else if (state is WishListStateError) {
            Utils.errorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is WishListStateLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2, color: Color(0xFF444444),
              ),
            );
          }
          if (state is WishListStateInitial) {
            return const SizedBox();
          }
          return _LoadedWidget(topPadding: topPadding);
        },
      ),
    );
  }
}

class _LoadedWidget extends StatefulWidget {
  const _LoadedWidget({required this.topPadding});
  final double topPadding;

  @override
  State<_LoadedWidget> createState() => __LoadedWidgetState();
}

class __LoadedWidgetState extends State<_LoadedWidget> {
  List<WishListModel> productList = [];

  @override
  void initState() {
    super.initState();
    productList = context.read<WishListCubit>().wishList;
  }

  @override
  Widget build(BuildContext context) {
    // Get recommended products from home model
    List<ProductModel> recommended = [];
    try {
      final homeState = context.read<HomeControllerCubit>().state;
      if (homeState is HomeControllerLoaded) {
        recommended = context.read<HomeControllerCubit>().homeModel.topRatedProducts;
      }
    } catch (_) {}

    // Get quotes
    List<HomeQuoteModel> quotes = HomeQuoteModel.defaults;
    try {
      final homeState = context.read<HomeControllerCubit>().state;
      if (homeState is HomeControllerLoaded) {
        final apiQuotes = context.read<HomeControllerCubit>().homeModel.quotes;
        if (apiQuotes.isNotEmpty) quotes = apiQuotes;
      }
    } catch (_) {}

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            // Top spacing for app bar
            SliverToBoxAdapter(
              child: SizedBox(height: widget.topPadding + 60),
            ),

            // Header section
            SliverToBoxAdapter(child: _buildHeader()),

            // Wishlist items or empty state
            if (productList.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildWishlistItem(productList[index], index),
                  childCount: productList.length,
                ),
              )
            else
              SliverToBoxAdapter(child: _buildEmptyState()),

            // Clear wishlist button
            if (productList.isNotEmpty)
              SliverToBoxAdapter(child: _buildClearButton()),

            // Divider
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Container(height: 1, color: const Color(0xFF262626)),
              ),
            ),

            // "More products you may like" section
            if (recommended.isNotEmpty)
              SliverToBoxAdapter(child: _buildRecommendedSection(recommended)),

            // Quote section
            if (quotes.isNotEmpty)
              SliverToBoxAdapter(child: _buildQuoteSection(quotes)),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),

        // App bar overlay
        Positioned(
          left: 0, right: 0, top: 0,
          child: Container(
            color: const Color(0xFF131313).withValues(alpha: 0.95),
            child: SafeArea(
              bottom: false,
              child: SizedBox(
                height: 60,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, RouteNames.cartScreen),
                        child: const Icon(Icons.shopping_bag_outlined, size: 22, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR CURATED SELECTION',
            style: GoogleFonts.manrope(
              fontSize: 10, fontWeight: FontWeight.w400,
              color: Colors.white, height: 1.5, letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'The Wishlist',
            style: GoogleFonts.notoSerif(
              fontSize: 36, fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w300,
              color: const Color(0xFFE5E2E1), height: 1.11,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A personal gallery of silhouettes and textures\nchosen for the modern epicurean.',
            style: GoogleFonts.manrope(
              fontSize: 16, fontWeight: FontWeight.w300,
              color: const Color(0xFFC4C8C0), height: 1.63,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistItem(WishListModel item, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image with favorite button
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context, RouteNames.productDetailsScreen,
              arguments: item.slug,
            ),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFF1C1B1B)),
              child: Stack(
                children: [
                  // Product image
                  AspectRatio(
                    aspectRatio: 342 / 427.5,
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(item.thumbImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Favorite button top-right
                  Positioned(
                    right: 16,
                    top: 16,
                    child: FavoriteButton(productId: item.id),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Product info row: name+category on left, price on right
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context, RouteNames.productDetailsScreen,
              arguments: item.slug,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSerif(
                          fontSize: 20, fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFE5E2E1), height: 1.4,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.shortDescription.isNotEmpty
                            ? item.shortDescription.toUpperCase()
                            : (item.isFeatured == 1 ? 'FEATURED' : 'CURATED'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 12, fontWeight: FontWeight.w400,
                          color: const Color(0xFFC4C8C0), height: 1.33,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Price
                Text(
                  Utils.formatPrice(
                    item.offerPrice > 0 ? item.offerPrice : item.price,
                    context,
                  ),
                  style: GoogleFonts.manrope(
                    fontSize: 18, fontWeight: FontWeight.w300,
                    color: const Color(0xFFE5E2E1), height: 1.56,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ADD TO BAG button
          BlocListener<AddToCartCubit, AddToCartState>(
            listener: (context, state) {
              if (state is AddToCartStateAdded) {
                Utils.showSnackBar(context, state.message);
              } else if (state is AddToCartStateError) {
                Utils.errorSnackBar(context, state.message);
              }
            },
            child: GestureDetector(
              onTap: () {
                final dataModel = AddToCartModel(
                  quantity: 1,
                  productId: item.id,
                  image: item.thumbImage,
                  slug: item.slug,
                  token: '',
                  variantItems: const <ActiveVariantModel>{},
                );
                context.read<AddToCartCubit>().addToCart(dataModel);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF444444), width: 1),
                ),
                child: Center(
                  child: Text(
                    'ADD TO BAG',
                    style: GoogleFonts.manrope(
                      fontSize: 12, fontWeight: FontWeight.w400,
                      color: Colors.white, height: 1.33,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom spacing between items
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: const Color(0x4C0E0E0E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0x0C434842), width: 1),
        ),
        child: Column(
          children: [
            // Empty icon
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF444444), width: 1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.favorite_border, size: 28, color: Color(0xFF777777)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Curate more pieces to perfect\nyour seasonal edit.',
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 16, fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFC4C8C0), height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context, RouteNames.mainPage, (route) => false,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0x33E9C349), width: 1),
                ),
                child: Text(
                  'EXPLORE COLLECTION',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 12, fontWeight: FontWeight.w400,
                    color: Colors.white, height: 1.33,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () {
          context.read<WishListCubit>().clearWishList();
          setState(() => productList.clear());
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Center(
            child: Text(
              'CLEAR WISHLIST',
              style: GoogleFonts.manrope(
                fontSize: 11, fontWeight: FontWeight.w400,
                color: const Color(0xFF777777), letterSpacing: 1.5,
                decoration: TextDecoration.underline,
                decorationColor: const Color(0xFF777777),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(List<ProductModel> products) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'MORE PIECES YOU MAY LIKE',
              style: GoogleFonts.manrope(
                fontSize: 10, fontWeight: FontWeight.w400,
                color: const Color(0xFFA0A0A0), letterSpacing: 2, height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Explore More',
              style: GoogleFonts.notoSerif(
                fontSize: 28, fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w300,
                color: const Color(0xFFE5E2E1), height: 1.29,
                letterSpacing: -0.7,
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 340,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: products.length > 10 ? 10 : products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, index) => _buildRecommendedCard(products[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context, RouteNames.productDetailsScreen,
        arguments: product.slug,
      ),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Container(
              width: 200,
              height: 220,
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(color: Color(0xFF1C1B1B)),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(product.thumbImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: FavoriteButton(productId: product.id),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Product name
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSerif(
                fontSize: 16, fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFE5E2E1), height: 1.5,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            // Price
            Text(
              Utils.formatPrice(
                product.offerPrice > 0 ? product.offerPrice : product.price,
                context,
              ),
              style: GoogleFonts.manrope(
                fontSize: 14, fontWeight: FontWeight.w300,
                color: const Color(0xFFC4C8C0), height: 1.43,
              ),
            ),
            const SizedBox(height: 10),
            // ADD TO BAG
            GestureDetector(
              onTap: () {
                final dataModel = AddToCartModel(
                  quantity: 1,
                  productId: product.id,
                  image: product.thumbImage,
                  slug: product.slug,
                  token: '',
                  variantItems: const <ActiveVariantModel>{},
                );
                context.read<AddToCartCubit>().addToCart(dataModel);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF444444), width: 1),
                ),
                child: Center(
                  child: Text(
                    'ADD TO BAG',
                    style: GoogleFonts.manrope(
                      fontSize: 11, fontWeight: FontWeight.w400,
                      color: Colors.white, height: 1.33,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection(List<HomeQuoteModel> quotes) {
    final quote = quotes[0];
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        color: const Color(0xFF131313),
        child: Column(
          children: [
            Text(
              '— —',
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                color: const Color(0xFF474747),
                letterSpacing: 6,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: GoogleFonts.notoSerif(
                fontSize: 18, fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF919191), height: 1.6,
              ),
            ),
            if (quote.author != null && quote.author!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                '— ${quote.author}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w400,
                  color: const Color(0xFF474747),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              '— —',
              style: GoogleFonts.notoSerif(
                fontSize: 14,
                color: const Color(0xFF474747),
                letterSpacing: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
