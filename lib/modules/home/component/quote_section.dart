import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/home_quote_model.dart';

class QuoteSection extends StatelessWidget {
  const QuoteSection({
    super.key,
    required this.quotes,
    this.index = 0,
  });

  final List<HomeQuoteModel> quotes;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (quotes.isEmpty) return const SizedBox.shrink();
    final quote = quotes[index % quotes.length];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 32),
      color: const Color(0xFF131313),
      child: Column(
        children: [
          Text(
            '— —',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: const Color(0xFF474747),
              letterSpacing: 6,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            quote.text,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 18,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF919191),
              height: 1.6,
            ),
          ),
          if (quote.author != null && quote.author!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '— ${quote.author}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF474747),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Text(
            '— —',
            style: GoogleFonts.notoSerif(
              fontSize: 14,
              color: const Color(0xFF474747),
              letterSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }
}
