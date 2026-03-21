import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color white = Color(0xFFFFFFFF);
const Color primaryColor = Color(0xFF000000);
const Color blackColor = Color(0xFF1A1A1A);
const Color buttonTextColor = Color(0xff1D1D1D);
const Color bottomPanelColor = Color(0xFF222222);
const Color borderColor = Color(0xFF2A2A2A);
const Color greenColor = Color(0xFF4A4A4A);
const Color redColor = Color(0xFF333333);
const Color deepGreenColor = Color(0xFF3A3A3A);
final Color grayColor = const Color(0xFF1A1A1A).withOpacity(.3);
const Color lightningYellowColor = Color(0xFF000000);
const Color iconGreyColor = Color(0xff85959E);
const Color paragraphColor = Color(0xFF666666);
const Color appBgColor = Color(0xFF131313);
const Color scaffoldBGColor = Color(0xFF131313);
const Color cardBgGreyColor = Color(0xFF1B1B1B);
const Color cardBgColor = Color(0xFF1B1B1B);
const Color textGreyColor = Color(0xff919191);
const Color inputFieldBgColor = Color(0xFF1C1B1B);
const Color grayBorderColor = Color(0xff2A2A2A);
const Color imageBgColor = Color(0xFF262626);
const Color carouselColor = Color(0xFF2A2A2A);
const Color transparent = Colors.transparent;
const greenGradient = [lightningYellowColor, lightningYellowColor];

// #duration
const kDuration = Duration(milliseconds: 300);

final _borderRadius = BorderRadius.circular(4);

var inputDecorationTheme = InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  hintStyle: const TextStyle(fontSize: 18, height: 1.667, color: Color(0xFF5E5E5E)),
  border: OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Color(0xFF444444)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
  ),
  fillColor: const Color(0xFF1C1B1B),
  filled: true,
  focusColor: const Color(0xFF1C1B1B),
);

TextStyle headlineTextStyle(double size) => GoogleFonts.notoSerif(
    fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1), fontSize: size);

TextStyle paragraphTextStyle(double size) => GoogleFonts.manrope(
    fontWeight: FontWeight.w400, color: const Color(0xFF919191), fontSize: size);

final gredientColors = [
  [const Color(0xFF333333), const Color(0xFF1A1A1A)],
  [const Color(0xFF555555), const Color(0xFF333333)],
  [const Color(0xFF161616), const Color(0xFF3D3D3D)],
  [const Color(0xFF333333), const Color(0xFF1A1A1A)],
  [const Color(0xFF555555), const Color(0xFF333333)],
  [const Color(0xFF161616), const Color(0xFF3D3D3D)],
];

const double singleProductHeight = 244.0;
Border borderSide =
    Border.all(color: const Color.fromRGBO(0, 0, 0, 0.10), width: 1.5);

TextStyle simpleTextStyle(Color? color) => GoogleFonts.roboto(
    fontWeight: FontWeight.w400, fontSize: 16.0, color: color ?? textGreyColor);
