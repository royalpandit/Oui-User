import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../../widgets/primary_button.dart';
import '../controller/cubit/category_cubit.dart';
import '../model/filter_model.dart';

class DrawerFilter extends StatefulWidget {
  const DrawerFilter({super.key});

  @override
  State<DrawerFilter> createState() => _DrawerFilterState();
}

class _DrawerFilterState extends State<DrawerFilter> {
  RangeValues _currentRangeValues = const RangeValues(0, 600);
  final brands = <int>[];
  final variantsItem = <String>[];
  double maxValue = 1.0;
  double minValue = 1000.0;
  double testPrice = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryCubit, CategoryState>(
      builder: (context, state) {
        if (state is CategoryLoadingState) {
          return const Center(child: SizedBox());
        } else if (state is CategoryLoadedState) {
          for (var i in state.categoryProducts) {
            if (i.price < minValue) {
              minValue = i.price;
              debugPrint('minValue : $minValue');
            }
            if (i.price > maxValue) {
              maxValue = i.price;
              debugPrint('maxValue : $maxValue');
            }
          }
          //_currentRangeValues = RangeValues(minValue, maxValue);
          if (state.categoryProducts.isEmpty) {
            return const SizedBox();
          }
          final filterOptions =
              context.read<CategoryCubit>().productCategoriesModel;

          return Drawer(
            backgroundColor: const Color(0xFF131313),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Scaffold.of(context).closeEndDrawer();
                    },
                    icon: Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              width: 1.5,
                              color: const Color(0xFF5E5E5E))),
                      child: const Icon(
                        Icons.clear,
                        color: Color(0xFFE5E2E1),
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(Language.price.capitalizeByWord(),
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
                  ),
                  RangeSlider(
                    values: _currentRangeValues,
                    min: 0,
                    max: 4000,
                    activeColor: const Color(0xFFE5E2E1),
                    inactiveColor: const Color(0xFF2A2A2A),
                    labels: RangeLabels(
                      minValue.round().toString(),
                      maxValue.round().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _currentRangeValues = values;
                        minValue =
                            double.parse(values.start.round().toString());
                        maxValue = double.parse(values.end.round().toString());
                        debugPrint('$_currentRangeValues');
                        debugPrint("min: $minValue - max: $maxValue");
                      });
                    },
                  ),
                  Text(
                      "${Language.price.capitalizeByWord()} \$$minValue - \$$maxValue",
                      style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF919191)),
                  ),
                  const SizedBox(height: 16),
                  if (filterOptions.brands.isNotEmpty) ...[
                    Text(
                      Language.brand.capitalizeByWord(),
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE5E2E1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      children: [
                        ...List.generate(
                          filterOptions.brands.length,
                          (index) => InkWell(
                            onTap: () {
                              setState(() {
                                brands.add(filterOptions.brands[index].id);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 5),
                              color: brands.contains(
                                      filterOptions.brands[index].id)
                                  ? const Color(0xFFE5E2E1)
                                  : const Color(0xFF262626),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 4.0),
                                child: Text(
                                  filterOptions.brands[index].name,
                                  style: GoogleFonts.manrope(
                                      fontSize: 13,
                                      color: brands.contains(
                                              filterOptions.brands[index].id)
                                          ? const Color(0xFF131313)
                                          : const Color(0xFFE5E2E1)),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                  const SizedBox(height: 16),
                  if (filterOptions.activeVariants.isNotEmpty) ...[
                    ...List.generate(
                        filterOptions.activeVariants.length,
                        (index) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filterOptions.activeVariants[index].name
                                      .capitalizeByWord(),
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFE5E2E1),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (filterOptions.activeVariants[index]
                                    .activeVariantsItems.isNotEmpty) ...[
                                  Wrap(
                                    children: [
                                      ...List.generate(
                                        filterOptions.activeVariants[index]
                                            .activeVariantsItems.length,
                                        (i) => InkWell(
                                          onTap: () {
                                            setState(() {
                                              variantsItem.add(filterOptions
                                                  .activeVariants[index]
                                                  .activeVariantsItems[i]
                                                  .name);
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 5),
                                            color: variantsItem.contains(
                                                    filterOptions
                                                        .activeVariants[index]
                                                        .activeVariantsItems[
                                                            i]
                                                        .name)
                                                ? const Color(0xFFE5E2E1)
                                                : const Color(0xFF262626),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4.0),
                                              child: Text(
                                                filterOptions
                                                    .activeVariants[index]
                                                    .activeVariantsItems[i]
                                                    .name
                                                    .capitalizeByWord(),
                                                style: GoogleFonts.manrope(
                                                  fontSize: 13,
                                                  color: variantsItem.contains(
                                                          filterOptions
                                                              .activeVariants[
                                                                  index]
                                                              .activeVariantsItems[
                                                                  i]
                                                              .name)
                                                      ? const Color(0xFF131313)
                                                      : const Color(0xFFE5E2E1),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 16),
                              ],
                            ))
                  ],
                  const SizedBox(height: 20),
                  PrimaryButton(
                      text: Language.findProduct.capitalizeByWord(),
                      bgColor: const Color(0xFFE5E2E1),
                      textColor: const Color(0xFF131313),
                      borderRadiusSize: 0,
                      onPressed: () {
                        final data = FilterModelDto(
                          brands: brands,
                          variantItems: variantsItem,
                          minPrice: minValue,
                          maxPrice: maxValue,
                        );

                        context.read<CategoryCubit>().getFilterProducts(data);
                        Scaffold.of(context).closeEndDrawer();
                      }),
                ],
              ),
            ),
          );
        } else if (state is CategoryErrorState) {
          return Center(
            child: Text(state.errorMessage),
          );
        }
        return Center(
          child: SizedBox(
            child: Text(Language.somethingWentWrong.capitalizeByWord()),
          ),
        );
      },
    );
  }
}
