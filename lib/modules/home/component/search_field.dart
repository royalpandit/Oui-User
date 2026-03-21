import 'package:flutter/material.dart';

import '../../../core/router_name.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: TextFormField(
        onTap: () {
          FocusScope.of(context).unfocus();
          Navigator.pushNamed(context, RouteNames.productSearchScreen);
        },
        decoration: const InputDecoration(
          filled: true,
          fillColor: Color(0xFF1C1B1B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF2A2A2A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: Color(0xFF2A2A2A)),
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF5E5E5E), size: 20),
          hintText: 'Search Products',
          hintStyle: TextStyle(color: Color(0xFF5E5E5E), fontSize: 13),
          contentPadding: EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
