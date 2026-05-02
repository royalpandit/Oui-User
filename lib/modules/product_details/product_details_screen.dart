import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '/modules/product_details/component/loader_screen.dart';
import '/utils/language_string.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../try_on/try_on_constants.dart';
import '../../widgets/toggle_button_component.dart';
import '../cart/controllers/cart/cart_cubit.dart';
import '../home/component/home_app_bar.dart';
import 'component/bottom_sheet_widget.dart';
import 'component/description_component.dart';
import 'component/product_header_component.dart';
import 'component/rating_list_component.dart';
import 'component/related_products_list.dart';
import 'component/seller_info_component.dart';
import 'controller/cubit/product_details_cubit.dart';
import 'model/product_details_model.dart';
import 'model/product_details_product_model.dart';
import 'model/variant_detail_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key, required this.slug});

  final String slug;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int selectedIndex = 0;
  String? _selectedSize;
  String? _selectedColorCode;
  int? _selectedVariantId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductDetailsCubit>().getProductDetails(widget.slug);
    });
  }

  final _className = 'ProductDetailsScreen';

  String _variantColorKey(VariantDetailModel item) {
    final code = item.colorCode.toString().trim().toLowerCase();
    if (code.isNotEmpty) return code;
    return item.color.toString().trim().toLowerCase();
  }

  Map<String, List<VariantDetailModel>> _groupVariantsByColor(
      ProductDetailsProductModel product) {
    final grouped = <String, List<VariantDetailModel>>{};
    for (final item in product.variantDetails) {
      final key = _variantColorKey(item);
      grouped.putIfAbsent(key, () => <VariantDetailModel>[]).add(item);
    }
    return grouped;
  }

  VariantDetailModel? _resolveSelectedVariant(
      ProductDetailsProductModel product) {
    final variants = product.variantDetails;
    if (variants.isEmpty) return null;

    if ((_selectedVariantId ?? 0) > 0) {
      for (final item in variants) {
        if (item.id == _selectedVariantId) return item;
      }
    }

    if (_selectedColorCode != null) {
      for (final item in variants) {
        if (_variantColorKey(item) == _selectedColorCode &&
            (_selectedSize == null ||
                item.size.trim().toLowerCase() ==
                    _selectedSize!.trim().toLowerCase())) {
          return item;
        }
      }
    }

    return null;
  }

  void _applyDefaultVariantSelection(ProductDetailsProductModel product) {
    if (product.variantDetails.isEmpty) return;
    final resolved = _resolveSelectedVariant(product);
    if (resolved == null) return;
    final resolvedColorKey = _variantColorKey(resolved);
    final resolvedSize = resolved.size.toString().trim();
    final resolvedId = resolved.id;

    if (_selectedVariantId == resolvedId &&
        _selectedColorCode == resolvedColorKey &&
        _selectedSize == resolvedSize) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _selectedVariantId = resolvedId;
        _selectedColorCode = resolvedColorKey;
        _selectedSize = resolvedSize;
      });
    });
  }

  double _displayPrice(ProductDetailsProductModel product) {
    final selectedVariant = _resolveSelectedVariant(product);
    if (selectedVariant != null && selectedVariant.price > 0) {
      return selectedVariant.price;
    }
    if (product.offerPrice > 0) {
      return product.offerPrice;
    }
    return product.price;
  }

  List<String> _displayImages(ProductDetailsProductModel product,
      {List<dynamic> gallery = const []}) {
    final selectedVariant = _resolveSelectedVariant(product);
    final images = <String>[];

    if (selectedVariant != null) {
      final activeColor = _variantColorKey(selectedVariant);
      final matchingVariants = product.variantDetails
          .where((item) => _variantColorKey(item) == activeColor)
          .toList();
      for (final item in matchingVariants) {
        if (item.image.trim().isNotEmpty && !images.contains(item.image)) {
          images.add(item.image);
        }
      }
    }

    if (product.thumbImage.isNotEmpty && !images.contains(product.thumbImage)) {
      images.add(product.thumbImage);
    }
    for (final image in product.productImages) {
      if (image.trim().isNotEmpty && !images.contains(image)) {
        images.add(image);
      }
    }
    for (final item in gallery) {
      if (item != null &&
          item.image.isNotEmpty &&
          !images.contains(item.image)) {
        images.add(item.image);
      }
    }

    return images;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: BlocBuilder<ProductDetailsCubit, ProductDetailsState>(
          builder: (context, state) {
            if (state is ProductDetailsStateLoading) {
              return const DetailsPageLoading();
            }
            if (state is ProductDetailsStateError) {
              return Center(
                child: Text(
                  state.errorMessage,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: Colors.red.shade300),
                ),
              );
            }
            if (state is ProductDetailsStateLoaded) {
              return _buildLoadedPage(state.productDetailsModel);
            }
            log(state.toString(), name: _className);
            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildLoadedPage(ProductDetailsModel productDetailsModel) {
    _applyDefaultVariantSelection(productDetailsModel.product);
    final topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: ProductHeaderComponent(
                product: productDetailsModel.product,
                images: _displayImages(
                  productDetailsModel.product,
                  gallery: productDetailsModel.gallery,
                ),
                displayPrice: _displayPrice(productDetailsModel.product),
                actualPrice: productDetailsModel.product.price,
                selectedVariantId: _selectedVariantId,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: ToggleButtonComponent(
                  textList: [
                    Language.description,
                    Language.reviews,
                    'Seller Info',
                  ],
                  initialLabelIndex: 0,
                  onChange: (int i) {
                    setState(() {
                      selectedIndex = i;
                    });
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
            SliverToBoxAdapter(child: _getChild(productDetailsModel)),
            SliverToBoxAdapter(
              child: RelatedProductsList(productDetailsModel.relatedProducts),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
        _buildAppBar(productDetailsModel, topPadding),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildBottomButtons(productDetailsModel),
        ),
      ],
    );
  }

  Widget _buildAppBar(
      ProductDetailsModel productDetailsModel, double topPadding) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(24, topPadding + 12, 24, 12),
        decoration: const BoxDecoration(color: Color(0xFF0A0A0A)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: Colors.white),
            ),
            Text(
              'COLLECTION',
              style: GoogleFonts.notoSerif(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFA3A3A3),
                letterSpacing: 3.6,
                height: 1.56,
              ),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final url =
                        'https://theoui.ai/product/${productDetailsModel.product.slug}';
                    SharePlus.instance.share(ShareParams(
                        text: '${productDetailsModel.product.name}\n$url'));
                  },
                  child: const Icon(Icons.share_outlined,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, RouteNames.cartScreen),
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      return CartBadge(
                        count: context.read<CartCubit>().cartCount.toString(),
                        badgeColor: Colors.white,
                        iconColor: Colors.white,
                        countColor: Colors.black,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getChild(ProductDetailsModel productDetailsModel) {
    if (selectedIndex == 0) {
      return DescriptionComponent(
        productDetailsModel.product.longDescription,
        variantDetails: productDetailsModel.product.variantDetails,
        selectedSize: _selectedSize,
        selectedColorCode: _selectedColorCode,
        onSizeSelected: (size) {
          final grouped = _groupVariantsByColor(productDetailsModel.product);
          final activeColor = _selectedColorCode;
          if (activeColor == null || !grouped.containsKey(activeColor)) return;
          final target = grouped[activeColor]!
              .where((v) =>
                  v.size.toString().trim().toLowerCase() ==
                  size.trim().toLowerCase())
              .toList();
          if (target.isEmpty) return;
          setState(() {
            _selectedSize = target.first.size.toString();
            _selectedVariantId = target.first.id;
          });
        },
        onColorSelected: (colorKey) {
          final grouped = _groupVariantsByColor(productDetailsModel.product);
          if (!grouped.containsKey(colorKey)) return;
          final first = grouped[colorKey]!.first;
          setState(() {
            _selectedColorCode = colorKey;
            _selectedSize = first.size.toString();
            _selectedVariantId = first.id;
          });
        },
      );
    } else if (selectedIndex == 1) {
      return ReviewListComponent(
        productDetailsModel.productReviews,
        productId: productDetailsModel.product.id,
        productName: productDetailsModel.product.name,
        sellerId: productDetailsModel.product.vendorId,
        thumbImage: productDetailsModel.product.thumbImage,
      );
    } else if (selectedIndex == 2) {
      return SellerInfo(productDetailsModel: productDetailsModel);
    }
    return const SizedBox();
  }

  Widget _buildBottomButtons(ProductDetailsModel productDetailsModel) {
    final product = productDetailsModel.product;
    final showTryOn = isClothingCategory(product.category?.slug);
    final clothImageUrl = RemoteUrls.imageUrl(product.thumbImage);
    final clothType = clothTypeFromCategorySlug(product.category?.slug);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: 80 + bottomPadding,
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border(
          top: BorderSide(color: Color(0x33262626), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final result = await showModalBottomSheet<Map<String, String?>>(
                  context: context,
                  backgroundColor: const Color(0xFF1B1B1B),
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(),
                  builder: (_) => BottomSheetWidget(
                    product: product,
                    initialSize: _selectedSize,
                    initialColorKey: _selectedColorCode,
                    initialVariantId: _selectedVariantId,
                  ),
                );
                if (result != null && mounted) {
                  setState(() {
                    _selectedSize = result['size'];
                    _selectedColorCode = result['color_key'];
                    _selectedVariantId =
                        int.tryParse(result['variant_id'] ?? '');
                  });
                }
              },
              child: Container(
                height: double.infinity,
                color: const Color(0xFF171717),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_bag_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      'ADD TO CART',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.5,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: showTryOn
                  ? () {
                      Navigator.pushNamed(
                        context,
                        RouteNames.tryOnScreen,
                        arguments: {
                          'productName': product.name,
                          'clothImageUrl': clothImageUrl,
                          'clothType': clothType,
                        },
                      );
                    }
                  : null,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF262626), width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.checkroom, color: Colors.black, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      'TRY ON (AR)',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 1.5,
                        height: 1.5,
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
}
