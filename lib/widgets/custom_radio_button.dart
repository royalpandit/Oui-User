import 'package:flutter/material.dart';

class CustomRadioButton extends StatelessWidget {
  const CustomRadioButton({
    super.key,
    this.onTap,
    this.isSelected = true,
  });
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
            borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.all(4),
        child: isSelected
            ? const CircleAvatar(backgroundColor: Colors.grey)
            : null,
      ),
    );
  }
}
