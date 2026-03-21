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
      height: 64,
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        border: Border(
          top: BorderSide(color: Color(0xFF262626), width: 0.5),
        ),
      ),
      child: StreamBuilder<int>(
        initialData: 0,
        stream: controller.naveListener.stream,
        builder: (context, snapshot) {
          int selectedIndex = snapshot.data ?? 0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: Language.home.capitalizeByWord(),
                onTap: () => controller.naveListener.sink.add(0),
              ),
              _buildNavItem(
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag_rounded,
                label: Language.order.capitalizeByWord(),
                onTap: () => controller.naveListener.sink.add(1),
              ),
              _buildNavItem(
                index: 2,
                selectedIndex: selectedIndex,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: Language.profile.capitalizeByWord(),
                onTap: () => controller.naveListener.sink.add(2),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
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
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Top indicator line
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2,
              width: isSelected ? 24 : 0,
              color: isSelected ? const Color(0xFFE5E2E1) : Colors.transparent,
            ),
            const Spacer(),
            // Icon
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? const Color(0xFFE5E2E1) : const Color(0xFF5E5E5E),
              size: 22,
            ),
            const SizedBox(height: 4),
            // Label
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFFE5E2E1) : const Color(0xFF5E5E5E),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}