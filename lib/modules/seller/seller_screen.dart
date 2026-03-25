import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sliver_tools/sliver_tools.dart';
import '../../core/remote_urls.dart';
import '../../widgets/custom_image.dart';
import '../category/component/product_card.dart';

import '../category/controller/cubit/category_cubit.dart';
import 'model/single_seller_model.dart';

class BestSellerInformation extends StatefulWidget {
  const BestSellerInformation({super.key});

  // final String slug;
  // final String keyword;

  @override
  State<BestSellerInformation> createState() => _BestSellerInformationState();
}

class _BestSellerInformationState extends State<BestSellerInformation> {
  @override
  Widget build(BuildContext context) {
    final sellerRoute =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final name = sellerRoute['name'] as String;
    final keyword = sellerRoute['keyword'] as String;
    context.read<CategoryCubit>().getSellerProduct(keyword);

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          name,
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
        ),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoadingState) {
            return const Center(
              child: SizedBox(
                height: 28,
                width: 120,
                child: ShimmerLoader.rect(height: 12, width: 120)));
          } else if (state is SellerProductState) {
            if (state.sellerModel.products.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No Products Yet',
                        style: GoogleFonts.notoSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFE2E2E2),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This seller hasn\'t added any products yet. Check back later for new arrivals.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF777777),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: const Color(0xFF444444), width: 1),
                          ),
                          child: Text(
                            'GO BACK',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFE2E2E2),
                              letterSpacing: 2,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SellerProduct();
          } else if (state is CategoryErrorState) {
            return Center(
              child: Text(state.errorMessage,
                style: GoogleFonts.manrope(color: const Color(0xFF919191)),
              ),
            );
          }
          return Center(
            child: SizedBox(
              child: Text(
                'Something Went Wrong',
                  style: GoogleFonts.inter(color: const Color(0xFF919191)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SingleSellerInfo extends StatelessWidget {
  const SingleSellerInfo({super.key, required this.singleSellerModel});
  final SingleSellerModel singleSellerModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Banner image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 140.0,
            width: double.infinity,
            child: singleSellerModel.bannerImage.isNotEmpty
                ? CustomImage(
                    path: RemoteUrls.imageUrl(singleSellerModel.bannerImage),
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2A2A2A), Color(0xFF1B1B1B)],
                      ),
                    ),
                  ),
          ),
        ),
        // Logo + name centered below banner
        Transform.translate(
          offset: const Offset(0, -30),
          child: Column(
            children: [
              Container(
                height: 60.0,
                width: 60.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF2A2A2A),
                  border: Border.all(color: const Color(0xFF131313), width: 3),
                ),
                child: ClipOval(
                  child: CustomImage(
                    path: RemoteUrls.imageUrl(singleSellerModel.logo),
                    height: 36.0,
                    width: 36.0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                singleSellerModel.shopName,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
              if (singleSellerModel.address.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  singleSellerModel.address,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 12.0,
                    color: const Color(0xFF919191),
                  ),
                ),
              ],
              if (singleSellerModel.averageRating.isNotEmpty &&
                  singleSellerModel.averageRating != '0') ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      singleSellerModel.averageRating,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF919191),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SellerProduct extends StatelessWidget {
  const SellerProduct({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final sellerProduct = context.read<CategoryCubit>().sellerProductModel;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        sliver: MultiSliver(
          children: [
            SliverToBoxAdapter(
                child: SingleSellerInfo(
                    singleSellerModel: sellerProduct.singleSellerModel)),
            // Products count label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${sellerProduct.products.length} ${sellerProduct.products.length == 1 ? 'PRODUCT' : 'PRODUCTS'}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF919191),
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 280,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return ProductCard(
                      productModel: sellerProduct.products[index]);
                },
                childCount: sellerProduct.products.length,
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}
