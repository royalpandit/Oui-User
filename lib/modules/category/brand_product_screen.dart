import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../modules/home/model/product_model.dart';
import 'component/product_card.dart';
import 'controller/cubit/category_cubit.dart';

class BrandProductScreen extends StatefulWidget {
  const BrandProductScreen({super.key, required this.slug});
  final String slug;

  @override
  State<BrandProductScreen> createState() => _BrandProductScreenState();
}

class _BrandProductScreenState extends State<BrandProductScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().getBrandProduct(widget.slug);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> _filter(List<ProductModel> products) {
    if (_searchQuery.isEmpty) return products;
    final q = _searchQuery.toLowerCase();
    return products.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          'Brand Products',
          style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1)),
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
          } else if (state is CategoryLoadedState) {
            if (state.categoryProducts.isEmpty) {
              return Center(
                  child: Text('No Items',
                      style: GoogleFonts.manrope(
                          fontSize: 14, color: const Color(0xFF919191))));
            }
            final products = context.read<CategoryCubit>().brandProducts;
            final filtered = _filter(products);
            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text('No matching products',
                              style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  color: const Color(0xFF919191))))
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 304,
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              ProductCard(productModel: filtered[index]),
                        ),
                ),
              ],
            );
          } else if (state is CategoryErrorState) {
            return Center(
                child: Text(state.errorMessage,
                    style: GoogleFonts.manrope(
                        color: const Color(0xFF919191))));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style:
            GoogleFonts.manrope(fontSize: 14, color: const Color(0xFFE5E2E1)),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle:
              GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF919191)),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF919191), size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  }),
                  child: const Icon(Icons.close_rounded,
                      color: Color(0xFF919191), size: 18),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1B1B1B),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF5E5E5E)),
          ),
        ),
      ),
    );
  }
}
