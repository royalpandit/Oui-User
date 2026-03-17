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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Top Image Section - Minimalist & Large
              Expanded(
                flex: 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PageView.builder(
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
                              width: size.width * 0.7,
                            ),
                          ),
                        );
                      },
                    ),
                    // Skip Button - Professional Grey
                    Positioned(
                      top: 60,
                      right: 20,
                      child: TextButton(
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.5),
                        ),
                        child: Text(
                          Language.skipForNow.capitalizeByWord(),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Content Section - Integrated Look
              Expanded(
                flex: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Colors.black, // Kept black for a seamless OLED look
                  ),
                  child: Column(
                    children: [
                      // Step Indicator - iOS Style Pill
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _numPages,
                          (index) => _buildDot(index),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Animated Text Content
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _getTitle(_currentPage),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              color: Colors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _getSubtitle(_currentPage),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: Colors.black.withOpacity(0.7),
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Button - Updated to Premium White-on-Black style
                      SizedBox(
                        width: double.infinity,
                        height: 56,
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
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
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
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
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
      height: 4,
      width: isSelected ? 24 : 8,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
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