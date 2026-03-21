import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileOfferScreen extends StatelessWidget {
  const ProfileOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF131313),
        body: Stack(
          children: [
            // ── Scrollable content ──
            SingleChildScrollView(
              padding: EdgeInsets.only(
                top: topPad + 60,
                bottom: bottomPad + 32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 48),

                  // ── Hero section ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXCLUSIVE REWARDS',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                            height: 1.33,
                            letterSpacing: 2.40,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Curated\n',
                                style: GoogleFonts.notoSerif(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFE5E2E1),
                                  height: 1.25,
                                ),
                              ),
                              TextSpan(
                                text: 'Privileges',
                                style: GoogleFonts.notoSerif(
                                  fontSize: 48,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFBACBB7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Reserved for the obsidian tier. Explore our\nseasonal edits and private collection\nincentives.',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w300,
                            color: const Color(0xFFC4C8C0),
                            height: 1.63,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Hero image card ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      height: 428,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1B1B),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Opacity(
                        opacity: 0.80,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0xFF2A2A2A),
                                Color(0xFF1A1A1A),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.diamond_outlined,
                              size: 64,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // ── Offer Card 1: The Winter Selection (with image) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF201F1F),
                        border: Border.all(
                          color: const Color(0x0C434842),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image area
                          Container(
                            width: double.infinity,
                            height: 340,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF2E3D2E),
                                  Color(0xFF1C1B1B),
                                ],
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.ac_unit_rounded,
                                size: 48,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                          ),
                          // Content area
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tags row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2E3D2E),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'SEASONAL',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF97A894),
                                          height: 1.50,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'ENDS 30 NOV',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFFC4C8C0),
                                        height: 1.50,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 56),

                                Text(
                                  'The Winter\nSelection',
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFE5E2E1),
                                    height: 1.11,
                                  ),
                                ),

                                const SizedBox(height: 16),

                                Text(
                                  'Enjoy an exclusive reduction on our\ncurated knitwear and outerwear\ncollections.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFFC4C8C0),
                                    height: 1.50,
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Coupon code row
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0E0E0E),
                                    border: Border.all(
                                      color: const Color(0x33434842),
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'OUI-20',
                                        style: GoogleFonts.manrope(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          height: 1.50,
                                          letterSpacing: 4.80,
                                        ),
                                      ),
                                      Text(
                                        'COPY CODE',
                                        style: GoogleFonts.manrope(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFFE5E2E1),
                                          height: 1.33,
                                          letterSpacing: 1.20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // ── Offer Card 2: Fall Edit Completion (text only) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1B1B),
                        border: Border.all(
                          color: const Color(0x19434842),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 60),

                          Text(
                            'Fall Edit\nCompletion',
                            style: GoogleFonts.notoSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFE5E2E1),
                              height: 1.33,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Complement your wardrobe with 15% off\nall accessories and footwear.',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFFC4C8C0),
                              height: 1.63,
                            ),
                          ),

                          const SizedBox(height: 48),

                          Text(
                            'VALID UNTIL 15 NOV',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFC4C8C0),
                              height: 1.50,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Coupon row
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0x4C434842),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'FALL-EDIT',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    height: 1.43,
                                    letterSpacing: 2.80,
                                  ),
                                ),
                                Icon(Icons.copy_rounded,
                                    size: 16,
                                    color: Colors.white
                                        .withValues(alpha: 0.50)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // ── Offer Card 3: Priority Concierge ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority\nConcierge',
                            style: GoogleFonts.notoSerif(
                              fontSize: 24,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFE5E2E1),
                              height: 1.33,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Text(
                            'Complimentary global express shipping\non all orders over \$500.',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFFC4C8C0),
                              height: 1.63,
                            ),
                          ),

                          const SizedBox(height: 32),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0x33E9C349),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'AUTO-APPLIED',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.50,
                                  letterSpacing: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // ── Offer Card 4: Private Shopping Event (with image) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      width: double.infinity,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0E0E0E),
                        border: Border.all(
                          color: const Color(0x0C434842),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image area
                          Opacity(
                            opacity: 0.60,
                            child: Container(
                              width: double.infinity,
                              height: 340,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFF3A2E1F),
                                    Color(0xFF1A1A1A),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.storefront_outlined,
                                  size: 48,
                                  color:
                                      Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                            ),
                          ),
                          // Content
                          Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LOYALTY REWARD',
                                  style: GoogleFonts.manrope(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFBACBB7),
                                    height: 1.50,
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Text(
                                  'Private\nShopping Event',
                                  style: GoogleFonts.notoSerif(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFE5E2E1),
                                    height: 1.25,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Text(
                                  'As an Obsidian member, you are invited\nto our Parisian flagship preview week.',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFFC4C8C0),
                                    height: 1.63,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                Row(
                                  children: [
                                    Text(
                                      'REQUEST INVITATION',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.50,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(Icons.arrow_forward,
                                        size: 14,
                                        color: Colors.white
                                            .withValues(alpha: 0.60)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // ── Terms footer ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 48),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Color(0x19434842),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'EXCLUSIVE OFFERS ARE SUBJECT TO AVAILABILITY AND\nMEMBER STATUS. TERMS AND CONDITIONS APPLY. SOME\nEXCLUSIONS MAY APPLY TO LIMITED EDITION CAPSULES.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFFC4C8C0),
                          height: 2,
                          letterSpacing: 1.50,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
              ),
            ),

            // ── Top bar (no back button) ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(
                  top: topPad + 16,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xE5131313),
                ),
                child: Center(
                  child: Text(
                    'THE EPICUREAN EDIT',
                    style: GoogleFonts.notoSerif(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      height: 1.56,
                      letterSpacing: 1.80,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}