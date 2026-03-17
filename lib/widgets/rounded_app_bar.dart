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
    this.textColor = Colors.black,
    this.bgColor = Colors.white,
    this.onTap,
    this.actions,
    super.key,
  }) : super(
          titleSpacing: 0,
          backgroundColor: bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: GoogleFonts.inter(
              color: textColor, fontSize: 17.0, fontWeight: FontWeight.w600),
          title: titleText != null ? Text(titleText!) : null,
          actions: actions,
          automaticallyImplyLeading: false,
        );
}
