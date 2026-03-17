import 'package:flutter/material.dart';
import 'constants.dart';

class AppStyle {
  AppStyle._();

  static const double radius = 12.0;

  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x1A000000), // black12
      blurRadius: 12,
      offset: Offset(0, 6),
    )
  ];

  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    )
  ];

  static Color accentColor = primaryColor;
  static Color surface = white;
  static Color inputBg = inputFieldBgColor;
  static Color icon = iconGreyColor;
}
