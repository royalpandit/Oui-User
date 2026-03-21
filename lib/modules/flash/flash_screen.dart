/*
import 'package:flutter/material.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import '/widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/core/remote_urls.dart';
import '/modules/flash/controller/cubit/flash_cubit.dart';
import '/widgets/custom_image.dart';
import '../category/component/product_card.dart';

class FlashScreen extends StatelessWidget {
  const FlashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<FlashCubit>().getFalshSale();
    return Scaffold(
        // appBar: AppBar(title: Text('Flash Products'),backgroundColor: Colors.white.withOpacity(0.5),),
        extendBodyBehindAppBar: true,

        body: BlocBuilder<FlashCubit, FlashState>(builder: (context, state) {
          print(state);
          if (state is FlashSaleLoading) {
            return const Center(
              child: SizedBox(
                height: 28,
                width: 120,
                child: ShimmerLoader.rect(height: 12, width: 120)));
          } else if (state is FlashSaleError) {
            return Center(child: Text(state.errorMessage));
          } else if (state is FlashSaleLoaded) {
            return Column(children: [
              SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImage(path: RemoteUrls.imageUrl(state.flashModel.flashSale.flashsalePageImage),fit: BoxFit.cover, ),
                    Positioned(
                      left: 10,top: 10,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        child: IconButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_rounded,color: Colors.black,),
                      ),),
                    )
                    // Text(state.flashModel.flashSale.title),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 290,
                    ),
                    itemCount: state.flashModel.products.length,
                    itemBuilder: (context,index){
                      return ProductCard(
                          productModel: state.flashModel.products[index]);
                    }

                ),
              )
            ],);
          } else {
            return const SizedBox();
          }
        }));
  }
}
*/

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '/core/remote_urls.dart';
import '/modules/flash/controller/cubit/flash_cubit.dart';
import '/widgets/custom_image.dart';
import '../category/component/product_card.dart';

class FlashScreen extends StatelessWidget {
  const FlashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FlashCubit>().getFalshSale();
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'Flash Sale',
          style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1)),
        ),
      ),
      body: BlocBuilder<FlashCubit, FlashState>(
        builder: (context, state) {
          if (state is FlashSaleLoading) {
            return _buildSkeleton(context);
          } else if (state is FlashSaleError) {
            return Center(
              child: Text(state.errorMessage,
                  style: GoogleFonts.inter(color: Colors.red.shade400)),
            );
          } else if (state is FlashSaleLoaded) {
            final sale = state.flashModel.flashSale;
            final endTime =
                DateTime.parse(sale.endTime).millisecondsSinceEpoch;
            final products = state.flashModel.products;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF1B1B1B),
                    width: double.infinity,
                    height: 220,
                    child: CustomImage(
                      path: RemoteUrls.imageUrl(sale.flashsalePageImage),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                // Info card: title, offer%, description, countdown
                SliverToBoxAdapter(
                  child: Container(
                    color: const Color(0xFF1B1B1B),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: Colors.amber, size: 22),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sale.title,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5E2E1),
                              ),
                              child: Text(
                                '${sale.offer}% OFF',
                                style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        if (sale.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            sale.description,
                            style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.white54,
                                height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text(
                              'Ends in  ',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white54,
                                  fontWeight: FontWeight.w500),
                            ),
                            CountdownTimer(
                              endTime: endTime,
                              widgetBuilder: (_, time) {
                                if (time == null) {
                                  return Text('Sale Over',
                                      style: GoogleFonts.inter(
                                          color: Colors.white54,
                                          fontSize: 12));
                                }
                                return Row(
                                  children: [
                                    _TimeUnit(
                                        value: time.days ?? 0, label: 'D'),
                                    _TimeDot(),
                                    _TimeUnit(
                                        value: time.hours ?? 0, label: 'H'),
                                    _TimeDot(),
                                    _TimeUnit(
                                        value: time.min ?? 0, label: 'M'),
                                    _TimeDot(),
                                    _TimeUnit(
                                        value: time.sec ?? 0, label: 'S'),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Products or empty state
                if (products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B1B1B),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.bolt_outlined,
                                size: 40, color: Color(0xFF5E5E5E)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE5E2E1)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Check back soon for flash deals!',
                            style: GoogleFonts.inter(
                                fontSize: 13, color: const Color(0xFF919191)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 280,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ProductCard(productModel: products[index]),
                        childCount: products.length,
                      ),
                    ),
                  ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: const Color(0xFF1B1B1B),
            highlightColor: const Color(0xFF2A2A2A),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.28,
              color: const Color(0xFF1B1B1B),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 280,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: const Color(0xFF1B1B1B),
                highlightColor: const Color(0xFF2A2A2A),
                child: Container(
                  color: const Color(0xFF1B1B1B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeUnit extends StatelessWidget {
  const _TimeUnit({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.white54,
                height: 1.2),
          ),
        ],
      ),
    );
  }
}

class _TimeDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Text(':',
          style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 14,
              fontWeight: FontWeight.w800)),
    );
  }
}
