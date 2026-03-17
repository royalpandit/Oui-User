import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '/widgets/capitalized_word.dart';
import '../../../utils/k_images.dart';
import '../../../utils/language_string.dart';
import '../main_controller.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MainController();
    return SizedBox(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: StreamBuilder(
          initialData: 0,
          stream: controller.naveListener.stream,
          builder: (_, AsyncSnapshot<int> index) {
            int selectedIndex = index.data ?? 0;
            return BottomNavigationBar(
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black),
              unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.grey.shade500,
              elevation: 8,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(KImages.homeIcon, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                  activeIcon: SvgPicture.asset(KImages.homeActive, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                  label: Language.home.capitalizeByWord(),
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(KImages.orderIcon, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                  activeIcon: SvgPicture.asset(KImages.orderActive, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                  label: Language.order.capitalizeByWord(),
                ),
                BottomNavigationBarItem(
                  tooltip: Language.profile.capitalizeByWord(),
                  activeIcon: SvgPicture.asset(KImages.profileActive, colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn)),
                  icon: SvgPicture.asset(KImages.profileIcon, colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn)),
                  label: Language.profile.capitalizeByWord(),
                ),
              ],
              currentIndex: selectedIndex,
              onTap: (int index) {
                controller.naveListener.sink.add(index);
              },
            );
          },
        ),
      ),
    );
  }
}
