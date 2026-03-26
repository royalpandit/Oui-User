import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class DescriptionComponent extends StatelessWidget {
  const DescriptionComponent(
    this.description, {
    super.key,
    this.sizes = const [],
    this.colors = const [],
    this.selectedSize,
    this.selectedColor,
    this.onSizeSelected,
    this.onColorSelected,
  });

  final String description;
  final List<String> sizes;
  final List<String> colors;
  final String? selectedSize;
  final String? selectedColor;
  final ValueChanged<String>? onSizeSelected;
  final ValueChanged<String>? onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sizes
          if (sizes.isNotEmpty) ...[
            Text(
              'AVAILABLE SIZES',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF919191),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sizes
                  .map((s) {
                    final isSelected = selectedSize == s;
                    return GestureDetector(
                      onTap: () => onSizeSelected?.call(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.white : Colors.transparent,
                          border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF444444),
                              width: 1),
                        ),
                        child: Text(
                          s.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFFE2E2E2),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Colors
          if (colors.isNotEmpty) ...[
            Text(
              'AVAILABLE COLORS',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF919191),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: colors
                  .map((c) {
                    final isSelected = selectedColor == c;
                    return GestureDetector(
                      onTap: () => onColorSelected?.call(c),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.white : Colors.transparent,
                          border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF444444),
                              width: 1),
                        ),
                        child: Text(
                          c.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: isSelected
                                ? Colors.black
                                : const Color(0xFFE2E2E2),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          // Description HTML
          Html(
            data: description,
            style: {
              '*': Style(
                color: const Color(0xFFD4D4D4),
                fontSize: FontSize(16),
                fontFamily: GoogleFonts.manrope().fontFamily,
                fontWeight: FontWeight.w300,
                lineHeight: const LineHeight(1.63),
              ),
              'h1': Style(
                color: Colors.white,
                fontSize: FontSize(24),
                fontFamily: GoogleFonts.notoSerif().fontFamily,
                fontWeight: FontWeight.w400,
              ),
              'h2': Style(
                color: Colors.white,
                fontSize: FontSize(20),
                fontFamily: GoogleFonts.notoSerif().fontFamily,
                fontWeight: FontWeight.w400,
              ),
              'h3': Style(
                color: Colors.white,
                fontSize: FontSize(18),
                fontFamily: GoogleFonts.notoSerif().fontFamily,
                fontWeight: FontWeight.w400,
              ),
              'strong': Style(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            },
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
