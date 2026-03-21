import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    super.key,
    this.maximumSize = const Size(double.infinity, 44),
    required this.text,
    this.fontSize = 18.0,
    required this.onPressed,
    this.minimumSize = const Size(double.infinity, 44),
    this.borderRadiusSize = 12.0,
    this.bgColor,
    this.textColor = Colors.white,
  });

  final VoidCallback? onPressed;
  final String text;
  final Size maximumSize;
  final Size minimumSize;
  final double fontSize;
  final double borderRadiusSize;
  Color? bgColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    bgColor ??= const Color(0xFFE5E2E1);

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        )),
        minimumSize: WidgetStateProperty.all(minimumSize),
        maximumSize: WidgetStateProperty.all(maximumSize),
        backgroundColor: WidgetStateProperty.all(bgColor),
        overlayColor: WidgetStateProperty.all(bgColor?.withValues(alpha: 0.85)),
        elevation: WidgetStateProperty.all(0),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
            color: textColor ?? const Color(0xFF131313),
            fontSize: fontSize,
            height: 1.5,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
