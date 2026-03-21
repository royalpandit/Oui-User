import 'package:flutter/material.dart';

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

  static Color accentColor = const Color(0xFFE5E2E1);
  static Color surface = const Color(0xFF1B1B1B);
  static Color inputBg = const Color(0xFF1C1B1B);
  static Color icon = const Color(0xFF919191);
}
