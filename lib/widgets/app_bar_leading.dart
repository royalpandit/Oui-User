import 'package:flutter/material.dart';

class AppbarLeading extends StatelessWidget {
  const AppbarLeading({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
      onPressed: () => Navigator.pop(context),
    );
  }
}
