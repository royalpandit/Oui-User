import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF262626), width: 1),
        ),
      ),
      child: Row(
        children: textList.asMap().entries.map((entry) {
          if (entry.value.isEmpty) return const SizedBox.shrink();
          final isSelected = initialLabelIndex == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() {
                initialLabelIndex = entry.key;
                widget.onChange(initialLabelIndex);
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  entry.value.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF737373),
                    letterSpacing: 2,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
