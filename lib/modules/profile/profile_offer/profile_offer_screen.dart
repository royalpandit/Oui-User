import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';

class ProfileOfferScreen extends StatelessWidget {
  const ProfileOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        // Standardized thin border for premium look
        shape: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        leading: IconButton(
          // Using a slightly more weighted icon for better visibility
          icon: const Icon(Icons.arrow_back_rounded, size: 24, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Language.myOffers.capitalizeByWord(),
          style: GoogleFonts.inter(
            fontSize: 16, 
            fontWeight: FontWeight.w700, 
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Iconography: Replacing empty text with a themed icon container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_offer_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
            ),
            const SizedBox(height: 24),
            
            // 2. Clear Headline
            Text(
              'No Offers Found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            
            // 3. Informative Subtitle
            Text(
              'Stay tuned! We will notify you as soon as a new offer is available for you.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // 4. Primary Call to Action
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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