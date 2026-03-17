import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '/widgets/capitalized_word.dart';
import '/utils/language_string.dart';
import 'controller/login/login_bloc.dart'; // Verified path

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pinController = TextEditingController();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                Language.verificationCode.capitalizeByWord(),
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We've sent a 6-digit verification code to your email address.",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              Center(
                child: Pinput(
                  controller: pinController,
                  length: 6,
                  autofocus: true,
                  defaultPinTheme: PinTheme(
                    height: 56,
                    width: 50,
                    textStyle: GoogleFonts.inter(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    height: 58,
                    width: 52,
                    textStyle: GoogleFonts.inter(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                  onCompleted: (String code) {
                    context
                        .read<LoginBloc>()
                        .add(AccountActivateCodeSubmit(code));
                  },
                ),
              ),
              const SizedBox(height: 40),
              // Resend Section
              Center(
                child: Column(
                  children: [
                    Text(
                      Language.didNotReceived.capitalizeByWord(),
                      style: GoogleFonts.inter(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Add resend logic if available in your bloc
                      },
                      child: Text(
                        Language.resend.capitalizeByWord(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Verify Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (pinController.text.length == 6) {
                      context.read<LoginBloc>().add(
                            AccountActivateCodeSubmit(pinController.text),
                          );
                    }
                  },
                  child: Text(
                    "Verify Now",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
