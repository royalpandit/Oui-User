import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/controller/cubit/products_cubit.dart';
import '../home/model/product_model.dart';
import 'component/product_card.dart';

class AllPopularProductScreen extends StatefulWidget {
  const AllPopularProductScreen({super.key});

  @override
  State<AllPopularProductScreen> createState() =>
      _AllPopularProductScreenState();
}

class _AllPopularProductScreenState extends State<AllPopularProductScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isInitialized = false;
  late String _appBarName;
  String? _keyword;
  List<ProductModel>? _directProducts;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final receivedValue =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _appBarName = receivedValue['app_bar'] as String;
      _keyword = receivedValue['keyword'] as String?;
      _directProducts = receivedValue['products'] as List<ProductModel>?;
      if (_directProducts == null && _keyword != null) {
        context.read<ProductsCubit>().getHighlightedProduct(_keyword!);
      }
    }
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
          _isInitialized ? _appBarName : '',
          style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1)),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _directProducts != null
                ? _buildProductGrid(_filter(_directProducts!))
                : BlocBuilder<ProductsCubit, ProductsState>(
                    builder: (context, state) {
                      if (state is ProductsStateLoading) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFE5E2E1)));
                      } else if (state is ProductsStateError) {
                        return _emptyState();
                      } else if (state is ProductsStateLoaded) {
                        return _buildProductGrid(
                            _filter(state.highlightedProducts));
                      }
                      return const SizedBox();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFFE5E2E1)),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF919191)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF919191), size: 20),
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

  Widget _buildProductGrid(List<ProductModel> products) {
    if (products.isEmpty) return _emptyState();
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 304,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) =>
          ProductCard(productModel: products[index]),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Text(
        _searchQuery.isNotEmpty ? 'No matching products' : 'No products found',
        style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF919191)),
      ),
    );
  }
}
