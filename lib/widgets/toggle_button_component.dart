import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/utils.dart';

class ToggleButtonComponent extends StatefulWidget {
  const ToggleButtonComponent({
    super.key,
    required this.onChange,
    required this.textList,
    this.initialLabelIndex = 0,
  });

  final void Function(int index) onChange;
  final int initialLabelIndex;
  final List<String> textList;

  @override
  State<ToggleButtonComponent> createState() => _ToggleButtonComponentState();
}

class _ToggleButtonComponentState extends State<ToggleButtonComponent> {
  late int initialLabelIndex;
  late List<String> textList;

  @override
  void initState() {
    super.initState();
    initialLabelIndex = widget.initialLabelIndex;
    textList = widget.textList;
  }

  List<Widget> getBtns() {
    final childList = <Widget>[];

    textList.asMap().forEach(
      (key, value) {
        childList.add(_buildSingleBtn(key, value));
      },
    );
    return childList;
  }

  Widget _buildSingleBtn(int key, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    final isSelected = initialLabelIndex == key;
    return Flexible(
      flex: 2,
      child: GestureDetector(
        onTap: () => setState(() {
          initialLabelIndex = key;
          widget.onChange(initialLabelIndex);
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13.0,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF6E6D79),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getBtns(),
      ),
    );
  }
}
