import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../home/model/product_model.dart';
import 'component/product_card.dart';

class AllFlashDealProductScreen extends StatefulWidget {
  const AllFlashDealProductScreen({super.key, required this.products});
  final List<ProductModel> products;

  @override
  State<AllFlashDealProductScreen> createState() =>
      _AllFlashDealProductScreenState();
}

class _AllFlashDealProductScreenState extends State<AllFlashDealProductScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final filtered = _filter(widget.products);
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
          'Flash Deal',
          style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFE5E2E1)),
        ),
      ),
      body: widget.products.isEmpty
          ? Center(
              child: Text('No Items',
                  style: GoogleFonts.manrope(
                      fontSize: 14, color: const Color(0xFF919191))))
          : Column(
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
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 304,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              ProductCard(productModel: filtered[index]),
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
