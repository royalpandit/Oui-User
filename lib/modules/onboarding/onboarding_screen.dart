import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import '../../core/router_name.dart';
import '../../widgets/custom_image.dart';
import '../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _numPages = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // Dark icons for white background
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // --- TOP SECTION: Skip Button ---
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text(
                      Language.skipForNow.capitalizeByWord(),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // --- MIDDLE SECTION: Large Image ---
              Expanded(
                flex: 5,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _numPages,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: CustomImage(
                          path: 'assets/icon/${index + 1}.png',
                          fit: BoxFit.contain,
                          width: size.width * 0.75,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // --- BOTTOM SECTION: Content & Actions ---
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      // Step Indicator Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _numPages,
                          (index) => _buildDot(index),
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Animated Text Content
                      Text(
                        _getTitle(_currentPage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A), // Near black
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _getSubtitle(_currentPage),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const Spacer(),

                      // Action Button - High Contrast Professional Style
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _numPages - 1) {
                              _navigateToLogin();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A), // Solid Black
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == _numPages - 1
                                ? "Get Started"
                                : Language.next.capitalizeByWord(),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToLogin() {
    context.read<AppSettingCubit>().cachOnBoarding();
    Navigator.pushNamedAndRemoveUntil(
        context, RouteNames.authenticationScreen, (route) => false);
  }

  Widget _buildDot(int index) {
    bool isSelected = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 6,
      width: isSelected ? 28 : 8,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1A1A1A) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  String _getTitle(int index) {
    List<String> titles = [
      "Find Your Favorites",
      "Easy Payment",
      "Fast Delivery"
    ];
    return titles[index];
  }

  String _getSubtitle(int index) {
    List<String> subs = [
      "Discover the best groceries and daily essentials from your favorite local stores.",
      "Secure and seamless checkout with multiple payment options for your convenience.",
      "Get your groceries delivered to your doorstep within minutes, fresh and safe."
    ];
    return subs[index];
  }
}