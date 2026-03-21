import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/capitalized_word.dart';
import '../../utils/language_string.dart';
import '../home/component/single_circuler_seller.dart';
import '../home/model/home_seller_model.dart';
import 'controller/cubit/category_cubit.dart';

class AllSellerList extends StatelessWidget {
  const AllSellerList({super.key, required this.sellers});
  final List<HomeSellerModel> sellers;


  @override
  Widget build(BuildContext context) {
    context.read<CategoryCubit>().getCategoryList();
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
          Language.allSeller.capitalizeByWord(),
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE5E2E1),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 160,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: sellers.length,
        itemBuilder: (context, index) {
          return SingleCircularSeller(
            seller: sellers[index],
          );
        },
      ),
    );
  }
}
