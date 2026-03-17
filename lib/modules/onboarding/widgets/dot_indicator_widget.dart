import 'package:flutter/material.dart';

class DotIndicatorWidget extends StatelessWidget {
  const DotIndicatorWidget({
    super.key,
    required this.currentIndex,
    required this.dotNumber,
  });

  final int currentIndex;
  final int dotNumber;

  @override
  Widget build(BuildContext context) {
    final dots = List.generate(
      dotNumber,
      (index) => _singleDot(index == currentIndex),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }

  Widget _singleDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 5),
      height: 10.0,
      width: 10.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
