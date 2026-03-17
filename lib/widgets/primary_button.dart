import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class PrimaryButton extends StatelessWidget {
  PrimaryButton({
    super.key,
    this.maximumSize = const Size(double.infinity, 52),
    required this.text,
    this.fontSize = 18.0,
    required this.onPressed,
    this.minimumSize = const Size(double.infinity, 52),
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
    bgColor ??= Colors.black;

    final borderRadius = BorderRadius.circular(borderRadiusSize);
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        shape: WidgetStateProperty.all(RoundedRectangleBorder(
          borderRadius: borderRadius,
          side: BorderSide(color: Colors.black.withOpacity(0.08)),
        )),
        minimumSize: WidgetStateProperty.all(minimumSize),
        maximumSize: WidgetStateProperty.all(maximumSize),
        backgroundColor: WidgetStateProperty.all(bgColor),
        overlayColor: WidgetStateProperty.all(bgColor?.withOpacity(0.85) ?? Colors.black.withOpacity(0.85)),
        elevation: WidgetStateProperty.all(6.0),
        shadowColor: WidgetStateProperty.all(Colors.black26),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
            color: textColor,
            fontSize: fontSize,
            height: 1.5,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
