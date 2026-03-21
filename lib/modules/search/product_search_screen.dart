import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '/widgets/capitalized_word.dart';
import '../../utils/language_string.dart';
import '../../utils/utils.dart';
import '../category/component/product_card.dart';
import 'components/rounded_app_bar.dart';
import 'controllers/search/search_bloc.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => ProductSearchScreenState();
}

class ProductSearchScreenState extends State<ProductSearchScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() {
    searchBloc = context.read<SearchBloc>();
    // Load all products initially
    searchBloc.add(const SearchEventSearch(''));

    _controller.addListener(() {
      final maxExtent = _controller.position.maxScrollExtent - 200;
      if (maxExtent < _controller.position.pixels) {
        searchBloc.add(const SearchEventLoadMore());
      }
    });
  }

  final searchCtr = TextEditingController();
  final _controller = ScrollController();

  late SearchBloc searchBloc;

  @override
  void dispose() {
    super.dispose();

    searchBloc.products.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: SearchAppBar(
        titleWidget: Container(
          margin: Utils.only(right: 20),
          height: 52,
          child: TextFormField(
            controller: searchCtr,
            textInputAction: TextInputAction.done,
            autofocus: true,
            style: GoogleFonts.manrope(fontSize: 16, color: const Color(0xFFE5E2E1)),
            cursorColor: const Color(0xFFE5E2E1),
            onChanged: (v) {
              context.read<SearchBloc>().add(SearchEventSearch(v.trim()));
            },
            onFieldSubmitted: (v) {
              context.read<SearchBloc>().add(SearchEventSearch(v.trim()));
            },
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: Language.searchProduct.capitalizeByWord(),
              hintStyle: GoogleFonts.manrope(fontSize: 16, color: const Color(0xFF5E5E5E)),
              filled: true,
              fillColor: const Color(0xFF1C1B1B),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search, color: Color(0xFF5E5E5E), size: 22),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 22),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF2A2A2A)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF2A2A2A)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFF444444)),
              ),
            ),
          ),
        ),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchStateMoreError) {
            Utils.errorSnackBar(context, state.message);
          } else if (state is SearchStateError) {
            Utils.errorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final products = searchBloc.products;
          if (products.isEmpty && state is SearchStateLoading) {
            return _buildSearchSkeleton();
          } else if (state is SearchStateError) {
            return Center(
              child: Text(
                state.message,
                style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF919191)),
              ),
            );
          } else if (products.isEmpty && state is SearchStateLoaded) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No products found',
                  style: GoogleFonts.manrope(fontSize: 15, color: const Color(0xFF5E5E5E)),
                ),
              ),
            );
          }
          return GridView.builder(
            controller: _controller,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 304.0,
            ),
            itemCount: products.length,
            itemBuilder: (BuildContext context, int index) {
              return ProductCard(productModel: products[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 304.0,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFF1B1B1B),
        highlightColor: const Color(0xFF2A2A2A),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 220, color: const Color(0xFF1B1B1B)),
            const SizedBox(height: 10),
            Container(height: 14, width: 120, color: const Color(0xFF1B1B1B)),
            const SizedBox(height: 6),
            Container(height: 12, width: 80, color: const Color(0xFF1B1B1B)),
            const SizedBox(height: 8),
            Container(height: 14, width: 60, color: const Color(0xFF1B1B1B)),
          ],
        ),
      ),
    );
  }
}
