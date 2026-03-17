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
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isExpanded ? Colors.black : Colors.grey.shade200,
              width: isExpanded ? 1.5 : 1,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              onExpansionChanged: (val) {
                setState(() => _expandedIndex = val ? index : -1);
              },
              initiallyExpanded: isExpanded,
              trailing: Icon(
                isExpanded ? Icons.remove_rounded : Icons.add_rounded,
                color: Colors.black,
                size: 20,
              ),
              title: Text(
                tile.question,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
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
                      color: Colors.grey.shade600,
                      lineHeight: LineHeight.number(1.6),
                    ),
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
