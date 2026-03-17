import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../../utils/k_images.dart';
import '../../../widgets/custom_image.dart';

class EmptyOrderComponent extends StatelessWidget {
  const EmptyOrderComponent(
      {super.key, this.iconColor = Colors.black54, this.emptySubTitle});

  final Color iconColor;
  final String? emptySubTitle;

  @override
  Widget build(BuildContext context) {
    final text = emptySubTitle ?? Language.noCartItem.capitalizeByWord();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: Column(
          children: [
            CustomImage(path: KImages.emptyOrder, color: iconColor),
            const SizedBox(height: 34),
            Text(
              Language.noItemsFound.capitalizeByWord(),
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            const SizedBox(height: 9),
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
