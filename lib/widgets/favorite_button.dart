import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/modules/product_details/controller/repository/product_details_repository.dart';
import '/modules/profile/profile_offer/controllers/wish_list/wish_list_cubit.dart';
import '../modules/profile/profile_offer/model/wish_list_model.dart';
import '../utils/language_string.dart';
import '../utils/utils.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    super.key,
    required this.productId,
    this.productSlug,
    this.variantId,
    this.isBg = true,
  });
  final int productId;
  final String? productSlug;
  final int? variantId;
  final bool isBg;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  Set<WishListModel> wishItem = {};
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    _syncFavState();
  }

  void _syncFavState() {
    final list = context.read<WishListCubit>().wishList;
    final match = list.where(_matchesWishlistItem).toSet();
    isFav = match.isNotEmpty;
    wishItem = match;
  }

  bool _matchesWishlistItem(WishListModel item) {
    if (item.id != widget.productId) return false;
    final selectedVariantId = widget.variantId ?? 0;
    if (selectedVariantId <= 0) return true;
    return item.variantId <= 0 || item.variantId == selectedVariantId;
  }

  Future<int> _resolveVariantId() async {
    final explicitVariantId = widget.variantId ?? 0;
    if (explicitVariantId > 0) return explicitVariantId;

    final slug = widget.productSlug;
    if (slug == null || slug.isEmpty) return 0;

    final result = await context.read<ProductDetailsRepository>().getProductDetails(slug);
    return result.fold(
      (failure) => 0,
      (data) => data.product.variantDetails.isNotEmpty
          ? data.product.variantDetails.first.id
          : 0,
    );
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.variantId != widget.variantId ||
        oldWidget.productSlug != widget.productSlug) {
      _syncFavState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WishListCubit, WishListState>(
      listener: (context, state) {
        if (state is WishListStateError) {
          Utils.errorSnackBar(context, state.message);
        } else if (state is WishListStateSuccess) {
          Utils.showSnackBar(context, state.message);
        } else if (state is WishListStateLoaded) {
          final match = state.productList.where(_matchesWishlistItem).toSet();
          setState(() {
            wishItem = match;
            isFav = match.isNotEmpty;
          });
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (isFav) {
            if (wishItem.isNotEmpty) {
              await context
                  .read<WishListCubit>()
                  .removeWishList(wishItem.first);
            } else {
              Utils.showSnackBar(context, Language.somethingWentWrong);
            }
          } else {
            final resolvedVariantId = await _resolveVariantId();
            await context
                .read<WishListCubit>()
                .addWishList(widget.productId, resolvedVariantId);
          }
        },
        child: Container(
          height: 36,
          width: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B1B).withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF474747), width: 0.5),
          ),
          child: Icon(
            isFav ? Icons.favorite : Icons.favorite_border,
            color: isFav ? Colors.redAccent : const Color(0xFFE2E2E2),
            size: 18,
          ),
        ),
      ),
    );
  }
}