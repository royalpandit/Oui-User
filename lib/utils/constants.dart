import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color white = Color(0xFFFFFFFF);
const Color primaryColor = Color(0xFF000000);
const Color blackColor = Color(0xFF1A1A1A);
const Color buttonTextColor = Color(0xff1D1D1D);
const Color bottomPanelColor = Color(0xFF222222);
const Color borderColor = Color(0xFFE0E0E0);
const Color greenColor = Color(0xFF4A4A4A);
const Color redColor = Color(0xFF333333);
const Color deepGreenColor = Color(0xFF3A3A3A);
final Color grayColor = const Color(0xFF1A1A1A).withOpacity(.3);
const Color lightningYellowColor = Color(0xFF000000);
const Color iconGreyColor = Color(0xff85959E);
const Color paragraphColor = Color(0xFF666666);
const Color appBgColor = Color(0xFFFFFFFF);
const Color scaffoldBGColor = Color(0xFFFFFFFF);
const Color cardBgGreyColor = Color(0xFFEDEDED);
const Color cardBgColor = Color(0xFFF6F6F6);
const Color textGreyColor = Color(0xff797979);
const Color inputFieldBgColor = Color(0xFFF8F8F8);
const Color grayBorderColor = Color(0xffE8E8E8);
const Color imageBgColor = Color(0xFFF5F5F5);
const Color carouselColor = Color(0xFFD9D9D9);
const Color transparent = Colors.transparent;
const greenGradient = [lightningYellowColor, lightningYellowColor];

// #duration
const kDuration = Duration(milliseconds: 300);

final _borderRadius = BorderRadius.circular(4);

var inputDecorationTheme = InputDecoration(
  isDense: true,
  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  hintStyle: const TextStyle(fontSize: 18, height: 1.667),
  border: OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Colors.white),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Colors.white),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: _borderRadius,
    borderSide: const BorderSide(color: Colors.white),
  ),
  fillColor: white,
  filled: true,
  focusColor: white,
);

TextStyle headlineTextStyle(double size) => GoogleFonts.jost(
    fontWeight: FontWeight.w600, color: blackColor, fontSize: size);

TextStyle paragraphTextStyle(double size) => GoogleFonts.inter(
    fontWeight: FontWeight.w400, color: Colors.grey, fontSize: size);

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
