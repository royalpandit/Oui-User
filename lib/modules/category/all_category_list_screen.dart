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
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final appBarName = receivedValue['app_bar'] as String;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          appBarName,
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoadingState) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is CategoryListLoadedState ||
              state is CategoryLoadedState) {
            final categories = context.read<CategoryCubit>().categoryList;
            if (categories.isEmpty) {
              return Center(
                  child: Text(
                Language.noCategory.capitalizeByWord(),
                style: GoogleFonts.inter(fontSize: 15, color: Colors.grey.shade500),
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
              child: Text(state.errorMessage, style: GoogleFonts.inter(color: Colors.red.shade400)),
            );
          }
          return Center(
            child: Text(Language.somethingWentWrong.capitalizeByWord(),
                style: GoogleFonts.inter(color: Colors.grey.shade500)),
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
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
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
