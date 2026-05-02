import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/remote_urls.dart';
import '../../../core/router_name.dart';
import '../../../utils/utils.dart';
import '../../../widgets/custom_image.dart';
import '../profile_offer/model/wish_list_model.dart';

class WishListCard extends StatefulWidget {
  const WishListCard({
    super.key,
    required this.product,
  });

  final WishListModel product;

  @override
  State<WishListCard> createState() => _WishListCardState();
}

class _WishListCardState extends State<WishListCard> {
  @override
  Widget build(BuildContext context) {
    const double height = 120;
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RouteNames.productDetailsScreen,
            arguments: widget.product.slug);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Row(
          children: [
            Container(
              width: 125.0,
              height: height,
              padding: const EdgeInsets.symmetric(vertical: 5.0)
                  .copyWith(right: 6.0),
              // color: Colors.red,
              child: CustomImage(
                path: RemoteUrls.imageUrl(widget.product.displayImage),
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                          height: 1.4,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    if (_attributeLabel().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          _attributeLabel().toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  Utils.formatPrice(widget.product.price, context),
                  style: GoogleFonts.inter(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _attributeLabel() {
    final labels = <String>[
      if (widget.product.gender.trim().isNotEmpty)
        widget.product.gender.trim(),
      if (widget.product.clothType.trim().isNotEmpty)
        widget.product.clothType.trim(),
    ];
    return labels.join(' / ');
  }
}
