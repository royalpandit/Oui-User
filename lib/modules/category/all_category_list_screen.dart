import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/widgets/capitalized_word.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../utils/language_string.dart';
import '../../widgets/custom_image.dart';
import 'controller/cubit/category_cubit.dart';
import 'model/category_model.dart';

class AllCategoryListScreen extends StatelessWidget {
  const AllCategoryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<CategoryCubit>().getCategoryList();
    final receivedValue =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final appBarName = receivedValue?['app_bar'] as String? ?? 'Categories';
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
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoadingState) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE5E2E1)));
          } else if (state is CategoryListLoadedState ||
              state is CategoryLoadedState) {
            final categories = context.read<CategoryCubit>().categoryList;
            if (categories.isEmpty) {
              return Center(
                  child: Text(
                Language.noCategory.capitalizeByWord(),
                style: GoogleFonts.manrope(fontSize: 15, color: const Color(0xFF5E5E5E)),
              ));
            }

            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _categoryCard(context, categories[index]);
              },
            );
          } else if (state is CategoryErrorState) {
            return Center(
              child: Text(state.errorMessage, style: GoogleFonts.manrope(color: Colors.red.shade400)),
            );
          }
          return Center(
            child: Text(Language.somethingWentWrong.capitalizeByWord(),
                style: GoogleFonts.manrope(color: const Color(0xFF5E5E5E))),
          );
        },
      ),
    );
  }

  Widget _categoryCard(BuildContext context, CategoriesModel categories) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RouteNames.singleCategoryProductScreen,
        arguments: {
          'keyword': categories.slug,
          'app_bar': categories.name,
        },
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1C1B1B),
          border: Border.fromBorderSide(
            BorderSide(color: Color(0xFF2A2A2A), width: 0.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF262626),
                ),
                child: Center(
                  child: CustomImage(
                    path: RemoteUrls.imageUrl(categories.image),
                    fit: BoxFit.contain,
                    height: 70,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: Text(
                categories.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE5E2E1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
