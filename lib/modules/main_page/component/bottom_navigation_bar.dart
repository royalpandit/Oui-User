import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/capitalized_word.dart';
import '../../../utils/language_string.dart';
import '../main_controller.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainController();

    return Container(
      height: 70, // Standard professional height
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: StreamBuilder<int>(
        initialData: 0,
        stream: controller.naveListener.stream,
        builder: (context, snapshot) {
          int selectedIndex = snapshot.data ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  index: 0,
                  selectedIndex: selectedIndex,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: Language.home.capitalizeByWord(),
                  onTap: () => controller.naveListener.sink.add(0),
                ),
                _buildNavItem(
                  context,
                  index: 1,
                  selectedIndex: selectedIndex,
                  icon: Icons.shopping_bag_outlined,
                  activeIcon: Icons.shopping_bag_rounded,
                  label: Language.order.capitalizeByWord(),
                  onTap: () => controller.naveListener.sink.add(1),
                ),
                _buildNavItem(
                  context,
                  index: 2,
                  selectedIndex: selectedIndex,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: Language.profile.capitalizeByWord(),
                  onTap: () => controller.naveListener.sink.add(2),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required int selectedIndex,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          // 1. Box behind icon and name when selected
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.white : Colors.grey.shade500,
              size: 22,
            ),
            // 2. Animate text showing/hiding for a premium feel
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}