import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

class DescriptionComponent extends StatelessWidget {
  const DescriptionComponent(this.description, {super.key});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
