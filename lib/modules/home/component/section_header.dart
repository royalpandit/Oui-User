import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/capitalized_word.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    this.onTap,
    required this.headerText,
  });
  final String headerText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              headerText.capitalizeByWord(),
              style: GoogleFonts.notoSerif(
                fontSize: 28,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.italic,
                color: const Color(0xFFE2E2E2),
                height: 1.20,
              ),
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF919191),
                  letterSpacing: 0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}