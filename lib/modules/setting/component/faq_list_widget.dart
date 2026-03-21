import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/faq_model.dart';

class FaqListWidget extends StatefulWidget {
  const FaqListWidget({
    super.key,
    required this.faqList,
  });

  final List<FaqModel> faqList;

  @override
  State<FaqListWidget> createState() => _FaqListWidgetState();
}

class _FaqListWidgetState extends State<FaqListWidget> {
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.faqList.length, (index) {
        final tile = widget.faqList[index];
        final isExpanded = _expandedIndex == index;
        return Container(
          margin: const EdgeInsets.only(bottom: 1),
          decoration: BoxDecoration(
            color: isExpanded ? const Color(0xFF1C1B1B) : const Color(0xFF131313),
            border: Border(
              bottom: BorderSide(
                width: 1,
                color: const Color(0xFF434842).withOpacity(0.12),
              ),
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              childrenPadding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              onExpansionChanged: (val) {
                setState(() => _expandedIndex = val ? index : -1);
              },
              initiallyExpanded: isExpanded,
              trailing: Icon(
                isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                color: const Color(0xFFE5E2E1),
                size: 20,
              ),
              title: Text(
                tile.question,
                style: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE5E2E1),
                  height: 1.5,
                ),
              ),
              children: [
                Html(
                  data: tile.answer,
                  style: {
                    'body': Style(
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                      fontSize: FontSize(14),
                      color: const Color(0xFFC4C8C0),
                      lineHeight: LineHeight.number(1.7),
                    ),
                    'a': Style(color: const Color(0xFFE9C349)),
                    'strong': Style(color: const Color(0xFFE5E2E1)),
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
