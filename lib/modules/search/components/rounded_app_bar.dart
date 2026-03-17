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
    this.textColor = Colors.black,
    this.bgColor = Colors.white,
    this.onTap,
    super.key,
  }) : super(
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: GoogleFonts.inter(
              color: textColor, fontSize: 17, fontWeight: FontWeight.w600),
          title: titleWidget,
          automaticallyImplyLeading: false,
        );
}
