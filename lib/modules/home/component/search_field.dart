import 'package:flutter/material.dart';

import '../../../core/router_name.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60.0,
      // width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: TextFormField(
        onTap: () {
          FocusScope.of(context).unfocus();
          Navigator.pushNamed(context, RouteNames.productSearchScreen);
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey, size: 20),
          hintText: 'Search Products',
          hintStyle: Theme.of(context)
              .textTheme
              .labelMedium!
              .copyWith(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 40.0,
            horizontal: 16,
          ),
          // suffixIconConstraints:
          //     const BoxConstraints(maxHeight: 32, minWidth: 32),
        ),
      ),
    );
  }
}
