import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToggleButtonScrollComponent extends StatefulWidget {
  const ToggleButtonScrollComponent({
    super.key,
    required this.onChange,
    required this.textList,
    this.initialLabelIndex = 0,
  });

  final void Function(int index) onChange;
  final int initialLabelIndex;
  final List<String> textList;

  @override
  State<ToggleButtonScrollComponent> createState() =>
      _ToggleButtonScrollComponentState();
}

class _ToggleButtonScrollComponentState
    extends State<ToggleButtonScrollComponent> {
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
    final isSelected = initialLabelIndex == key;
    return InkWell(
      onTap: () => setState(() {
        initialLabelIndex = key;
        widget.onChange(initialLabelIndex);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: textList.length - 1 == key ? 0.0 : 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: getBtns(),
        ),
      ),
    );
  }
}
