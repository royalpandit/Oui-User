import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/variant_detail_model.dart';

class DescriptionComponent extends StatelessWidget {
  const DescriptionComponent(
    this.description, {
    super.key,
    this.variantDetails = const [],
    this.selectedSize,
    this.selectedColorCode,
    this.onSizeSelected,
    this.onColorSelected,
  });

  final String description;
  final List<VariantDetailModel> variantDetails;
  final String? selectedSize;
  final String? selectedColorCode;
  final ValueChanged<String>? onSizeSelected;
  final ValueChanged<String>? onColorSelected;

  static String _colorGroupKey(VariantDetailModel item) {
    final code = item.colorCode.trim().toLowerCase();
    if (code.isNotEmpty) return code;
    return item.color.trim().toLowerCase();
  }

  static Color _parseColor(String colorCode) {
    final raw = colorCode.trim();
    if (raw.isEmpty) return const Color(0xFF666666);
    String hex = raw.startsWith('#') ? raw.substring(1) : raw;
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xFF666666);
    return Color(value);
  }

  @override
  Widget build(BuildContext context) {
    final cleanedDescription = description
      .replaceAll(RegExp(r'\byets\b', caseSensitive: false), '')
      .trim();

    final groupedByColor = <String, List<VariantDetailModel>>{};
    for (final item in variantDetails) {
      final key = _colorGroupKey(item);
      groupedByColor.putIfAbsent(key, () => <VariantDetailModel>[]).add(item);
    }

    final colorGroups = groupedByColor.entries.toList();
    final activeColorKey = (selectedColorCode != null &&
            groupedByColor.containsKey(selectedColorCode!.trim().toLowerCase()))
        ? selectedColorCode!.trim().toLowerCase()
        : null;
    final activeColorVariants =
        activeColorKey != null ? groupedByColor[activeColorKey]! : variantDetails;
    final availableSizes = activeColorVariants
        .map((e) => e.size.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (colorGroups.isNotEmpty) ...[
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
              spacing: 14,
              runSpacing: 12,
              children: colorGroups.map((entry) {
                    final first = entry.value.first;
                    final isSelected = entry.key == activeColorKey;
                    final displayName =
                        first.color.trim().isNotEmpty ? first.color.trim() : first.name.trim();
                    return GestureDetector(
                      onTap: () => onColorSelected?.call(entry.key),
                      child: Column(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _parseColor(first.colorCode),
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF3A3A3A),
                                  width: isSelected ? 2 : 1),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: 64,
                            child: Text(
                              displayName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFFE2E2E2),
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          if (availableSizes.isNotEmpty) ...[
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
              children: availableSizes
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
          // Description HTML
          if (cleanedDescription.isNotEmpty)
            Html(
              data: cleanedDescription,
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
