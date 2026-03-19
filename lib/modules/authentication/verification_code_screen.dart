import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '/widgets/capitalized_word.dart';
import '/utils/language_string.dart';
import '../../core/router_name.dart';
import 'controller/login/login_bloc.dart'; // Verified path

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final pinController = TextEditingController();
  bool _isSubmitting = false;
  bool _isVerified = false;

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  void _submitCode(BuildContext context) {
    if (_isSubmitting || _isVerified) return;
    if (pinController.text.length == 6) {
      context.read<LoginBloc>().add(
            AccountActivateCodeSubmit(pinController.text),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: BlocListener<LoginBloc, LoginModelState>(
        listenWhen: (prev, curr) => prev.state != curr.state,
        listener: (context, modelState) {
          final loginState = modelState.state;
          if (loginState is LoginStateLoading) {
            setState(() => _isSubmitting = true);
          } else if (loginState is AccountActivateSuccess) {
            setState(() {
              _isSubmitting = false;
              _isVerified = true;
            });
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteNames.authenticationScreen,
              (route) => false,
            );
          } else if (loginState is LoginStateError) {
            setState(() => _isSubmitting = false);
            final msg = loginState.errorMsg.toLowerCase();
            if (msg.contains('invalid token') || msg.contains('already')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Already verified. Please sign in.'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteNames.authenticationScreen,
                (route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(loginState.errorMsg),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: SafeArea(
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
                    _submitCode(context);
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
                  onPressed: _isSubmitting || _isVerified
                      ? null
                      : () => _submitCode(context),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          _isVerified ? "Verified" : "Verify Now",
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
      ),
    );
  }
}
