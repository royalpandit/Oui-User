import 'package:flutter/material.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../widgets/rounded_app_bar.dart';
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
      backgroundColor: Colors.white,
      appBar: RoundedAppBar(
        titleText: appBarName,
        bgColor: Colors.white,
        onTap: () {
          Navigator.pop(context);
        },
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state is ProductsStateLoading) {
            return const Center(
              child: SizedBox(
                height: 28,
                width: 120,
                child: ShimmerLoader.rect(height: 12, width: 120)));
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
