import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.color = Colors.black,
    this.onTap,
    required this.headerText,
    this.isSeeAll = true,
  });
  final Color? color;
  final String headerText;
  final VoidCallback? onTap;
  final bool isSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            headerText.capitalizeByWord(),
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
          isSeeAll? InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                Language.seeAll.capitalizeByWord(),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ):const SizedBox(),
        ],
      ),
    );
  }
}
