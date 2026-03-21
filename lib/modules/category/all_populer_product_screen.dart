import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/controller/cubit/products_cubit.dart';
import 'component/popular_product_card.dart';

class AllPopularProductScreen extends StatelessWidget {
  const AllPopularProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final receivedValue =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final appBarName = receivedValue['app_bar'] as String;
    final keyword = receivedValue['keyword'] as String;
    context.read<ProductsCubit>().getHighlightedProduct(keyword);
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
          appBarName,
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
        ),
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsStateLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE5E2E1)));
          } else if (state is ProductsStateError) {
          } else if (state is ProductsStateLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: state.highlightedProducts.length,
              itemBuilder: (context, index) => PopularProductCard(
                  productModel: state.highlightedProducts[index]),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
