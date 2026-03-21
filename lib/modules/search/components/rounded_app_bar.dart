import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';


class SearchAppBar extends AppBar {
  final Widget? titleWidget;
  final Color bgColor;
  final Color textColor;
  final void Function()? onTap;

  SearchAppBar({
    this.titleWidget,
    this.textColor = const Color(0xFFE5E2E1),
    this.bgColor = const Color(0xFF131313),
    this.onTap,
    super.key,
  }) : super(
          titleSpacing: 0,
          backgroundColor: const Color(0xFF131313),
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.manrope(
              color: textColor, fontSize: 16, fontWeight: FontWeight.w600),
          title: titleWidget,
          automaticallyImplyLeading: false,
        );
}
