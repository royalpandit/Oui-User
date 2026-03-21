import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/router_name.dart';

class PleaseSignInWidget extends StatelessWidget {
  const PleaseSignInWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1B1B),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 36,
                  color: Color(0xFF5E5E5E),
                ),
              ),
              const SizedBox(height: 32),
              // Heading
              Text(
                'Welcome to OUI',
                style: GoogleFonts.notoSerif(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFE5E2E1),
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Subtitle
              Text(
                'Sign in to access your orders, wishlist,\nand personalised experience.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF777777),
                  height: 1.57,
                ),
              ),
              const SizedBox(height: 48),
              // Sign in button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, RouteNames.authenticationScreen);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  color: const Color(0xFFE5E2E1),
                  alignment: Alignment.center,
                  child: Text(
                    'SIGN IN',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF131313),
                      letterSpacing: 3.6,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Continue browsing
              GestureDetector(
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.mainPage,
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'CONTINUE BROWSING',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE5E2E1),
                      letterSpacing: 3.6,
                      height: 1.33,
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 4),
              // Footer
              Opacity(
                opacity: 0.30,
                child: Column(
                  children: [
                    Container(width: 16, height: 1, color: const Color(0xFF5E5E5E)),
                    const SizedBox(height: 8),
                    Text(
                      'OUI The Premium Store',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: const Color(0xFF5E5E5E),
                        letterSpacing: 3,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
