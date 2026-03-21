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
                child: Text(
                  'No Item Found',
                  style: GoogleFonts.manrope(color: const Color(0xFF919191)),
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
    return Stack(
      children: [
        Container(
            height: 130.0,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 0.0),
            child: CustomImage(
                  path: RemoteUrls.imageUrl(singleSellerModel.bannerImage),
                  fit: BoxFit.cover)),
        Positioned.fill(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60.0,
                      width: 60.0,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Color(0xFF2A2A2A)),
                      child: Center(
                        child: CustomImage(
                          path: RemoteUrls.imageUrl(singleSellerModel.logo),
                          height: 30.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2.0),
                    Text(
                      singleSellerModel.shopName,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0,
                        color: const Color(0xFFE5E2E1),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSellerInfo(IconData icon, String info) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6.0, right: 10.0),
          child: Icon(
            icon,
            size: 20.0,
          ),
        ),
        Text(info),
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
            const SizedBox(height: 20),
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 300,
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
