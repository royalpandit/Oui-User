import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router_name.dart';
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

  static const _bgColor = Color(0xFF131313);

  final List<String> _images = [
    'assets/icons/1.png',
    'assets/icons/2.png',
    'assets/icons/3.png',
  ];

  final List<String> _titles = [
    'FIND YOUR\nFAVORITE\nCLOTHES',
    'EASY WAY\nTO SHOP',
    'TRY BEFORE\nYOU BUY',
  ];

  final List<String> _subtitles = [
    'Explore the latest styles and discover outfits\nyou\'ll love, all in one place.',
    'Browse, choose, and shop your favorites\nquickly with a smooth experience.',
    'Experience virtual try-on and see how outfits\nlook on you instantly.',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    context.read<AppSettingCubit>().cachOnBoarding();
    Navigator.pushNamedAndRemoveUntil(
        context, RouteNames.authenticationScreen, (route) => false);
  }

  void _onNext() {
    if (_currentPage == _numPages - 1) {
      _navigateToLogin();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
          children: [
            // PageView for swipeable content
            PageView.builder(
              controller: _pageController,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemCount: _numPages,
              itemBuilder: (context, index) => _buildPage(index),
            ),

            // Top bar: OUI + SKIP
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'OUI',
                      style: GoogleFonts.notoSerif(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        letterSpacing: -1.2,
                      ),
                    ),
                    if (_currentPage < _numPages - 1)
                      GestureDetector(
                        onTap: _navigateToLogin,
                        child: Text(
                          'SKIP',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    if (_currentPage == _numPages - 1)
                      const SizedBox.shrink(),
                  ],
                ),
              ),
            ),

            // Bottom bar: Back + NEXT
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back arrow - hidden on first page
                      if (_currentPage > 0)
                        GestureDetector(
                          onTap: _onBack,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 52),
                      // NEXT / GET STARTED button
                      GestureDetector(
                        onTap: _onNext,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          decoration: const BoxDecoration(color: Colors.white),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _numPages - 1 ? 'GET STARTED' : 'NEXT',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Icon(
                                Icons.arrow_forward,
                                color: Colors.black,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image at top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: ClipRect(
            child: Image.asset(
              _images[index],
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),

        // Gradient overlay - top fade only
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: MediaQuery.of(context).size.height * 0.55,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _bgColor,
                  _bgColor.withOpacity(0.6),
                  Colors.transparent,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.15, 0.4, 1.0],
              ),
            ),
          ),
        ),

        // Content at bottom - fixed top position for consistent alignment
        Positioned(
          left: 42,
          right: 42,
          top: MediaQuery.of(context).size.height * 0.55 + 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page indicator: 01 / 03
              Text(
                '${(index + 1).toString().padLeft(2, '0')} / 0$_numPages',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF919191),
                  letterSpacing: 3.6,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                _titles[index],
                style: GoogleFonts.notoSerif(
                  fontSize: 36,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: 3.6,
                ),
              ),
              const SizedBox(height: 24),

              // Subtitle
              Text(
                _subtitles[index],
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFC7C6C6),
                  height: 1.63,
                  letterSpacing: 0.35,
                ),
              ),
              const SizedBox(height: 20),

              // Line indicators
              Row(
                children: List.generate(_numPages, (i) {
                  return Container(
                    width: 48,
                    height: 2,
                    margin: EdgeInsets.only(right: i < _numPages - 1 ? 16 : 0),
                    color: i == index ? Colors.white : const Color(0xFF353535),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }
}