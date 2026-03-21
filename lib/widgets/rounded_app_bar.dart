import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class RoundedAppBar extends AppBar {
  final String? titleText;

  final Color bgColor;
  final Color textColor;
  final void Function()? onTap;
  final List<Widget>? actions;

  RoundedAppBar({
    this.titleText,
    this.textColor = const Color(0xFFE5E2E1),
    this.bgColor = const Color(0xFF131313),
    this.onTap,
    this.actions,
    super.key,
  }) : super(
          titleSpacing: 0,
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.manrope(
              color: textColor, fontSize: 16.0, fontWeight: FontWeight.w600),
          title: titleText != null ? Text(titleText!) : null,
          actions: actions,
          automaticallyImplyLeading: false,
        );
}
