import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/product_details/component/loader_screen.dart';
import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../try_on/try_on_constants.dart';
import '../../widgets/toggle_button_component.dart';
import '../cart/controllers/cart/cart_cubit.dart';
import '../home/component/home_app_bar.dart';
import 'component/bottom_sheet_widget.dart';
import 'component/description_component.dart';
import 'component/product_details_component.dart';
import 'component/product_header_component.dart';
import 'component/rating_list_component.dart';
import 'component/related_products_list.dart';
import 'component/seller_info_component.dart';
import 'controller/cubit/product_details_cubit.dart';
import 'model/product_details_model.dart';
import 'model/product_details_product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.slug});

  final String slug;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        context.read<ProductDetailsCubit>().getProductDetails(widget.slug));
  }

  final _className = 'ProductDetailsScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(builder: (context) {
        return BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            if (state is ProductDetailsStateLoading) {
              return const Center(child: DetailsPageLoading());
            }
            if (state is ProductDetailsStateError) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.red),
                ),
              );
            }
            if (state is ProductDetailsStateLoaded) {
              return _buildLoadedPage(state.productDetailsModel);
            }
            log(state.toString(), name: _className);
            return const SizedBox();
          },
        );
      }),
    );
  }

  Widget _buildLoadedPage(ProductDetailsModel productDetailsModel) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              floating: true,
              pinned: false,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              centerTitle: true,
              title: Text(
                Language.productDetails.capitalizeByWord(),
                style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ),
            SliverToBoxAdapter(
              child: ProductHeaderComponent(
                  product: productDetailsModel.product,
                  gallery: productDetailsModel.gallery),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(
              child: ProductDetailsComponent(
                detailsModel: productDetailsModel,
                product: productDetailsModel.product,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: ToggleButtonComponent(
                textList: [
                  Language.description.capitalizeByWord(),
                  '${Language.reviews.capitalizeByWord()} (${productDetailsModel.productReviews.length})',
                  productDetailsModel.isSellerProduct == true
                      ? Language.sellerInfo
                      : '',
                ],
                initialLabelIndex: 0,
                onChange: (int i) {
                  setState(() {
                    selectedIndex = i;
                  });
                },
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            SliverToBoxAdapter(child: getChild(productDetailsModel)),
            SliverToBoxAdapter(
              child: RelatedProductsList(productDetailsModel.relatedProducts),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        _buildBottomButtons(productDetailsModel.product),
      ],
    );
  }

  Widget getChild(ProductDetailsModel productDetailsModel) {
    debugPrint(
        'product-details ${productDetailsModel.product.longDescription}');
    if (selectedIndex == 0) {
      return DescriptionComponent(productDetailsModel.product.longDescription);
    } else if (selectedIndex == 1) {
      return ReviewListComponent(productDetailsModel.productReviews);
    } else if (selectedIndex == 2) {
      return SellerInfo(productDetailsModel: productDetailsModel);
    }
    return const SizedBox();
  }

  Widget _buildBottomButtons(ProductDetailsProductModel product) {
    final cartProducts = context.read<CartCubit>();
    final showTryOn = isClothingCategory(product.category?.slug);
    final clothImageUrl = RemoteUrls.imageUrl(product.thumbImage);
    final clothType = clothTypeFromCategorySlug(product.category?.slug);

    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding > 0 ? bottomPadding : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, RouteNames.cartScreen);
            },
            child: SizedBox(
              height: 50,
              width: 50,
              child: BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  return CartBadge(
                    count: cartProducts.cartCount.toString(),
                    badgeColor: Colors.black,
                    iconColor: Colors.black,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (showTryOn) ...[
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.tryOnScreen,
                    arguments: {
                      'productName': product.name,
                      'clothImageUrl': clothImageUrl,
                      'clothType': clothType,
                    },
                  );
                },
                child: Container(
                  height: 50.0,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.checkroom, color: Colors.black, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        'Try on',
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20),
                      ),
                    ),
                    builder: (_) => BottomSheetWidget(product: product));
              },
              child: Container(
                width: double.infinity,
                height: 50.0,
                decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, color: Colors.white, size: 24.0),
                    const SizedBox(width: 6),
                    Text(
                      Language.addToCart.capitalizeByWord(),
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
