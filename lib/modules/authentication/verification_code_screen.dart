import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../core/router_name.dart';
import 'controller/login/login_bloc.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final pinController = TextEditingController();
  bool _isSubmitting = false;
  bool _isVerified = false;

  // Timer
  late Timer _timer;
  int _secondsRemaining = 300; // 5 minutes
  bool _timerActive = true;

  static const _bgColor = Color(0xFF131313);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer.cancel();
        setState(() => _timerActive = false);
      }
    });
  }

  String get _timerText {
    final m = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer.cancel();
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _bgColor,
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
              // Show verified overlay then navigate
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteNames.authenticationScreen,
                    (route) => false,
                  );
                }
              });
            } else if (loginState is LoginStateError) {
              setState(() => _isSubmitting = false);
              final msg = loginState.errorMsg.toLowerCase();
              if (msg.contains('invalid token') || msg.contains('already')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
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
          child: Stack(
            children: [
              // Main content
              SafeArea(
                child: Column(
                  children: [
                    // App bar
                    Container(
                      width: double.infinity,
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'VERIFICATION',
                            style: GoogleFonts.notoSerif(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),

                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            // Title section
                            Text(
                              'Verification Code',
                              style: GoogleFonts.notoSerif(
                                fontSize: 36,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFE2E2E2),
                                height: 1.11,
                                letterSpacing: -0.9,
                              ),
                            ),
                            const SizedBox(height: 23),
                            Text(
                              'We\u2019ve sent a 6-digit verification code to your\nemail address.',
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFC7C6C6),
                                height: 1.63,
                              ),
                            ),
                            const SizedBox(height: 64),

                            // PIN input
                            Center(
                              child: Pinput(
                                controller: pinController,
                                length: 6,
                                autofocus: true,
                                defaultPinTheme: PinTheme(
                                  height: 48,
                                  width: 48,
                                  textStyle: GoogleFonts.notoSerif(
                                    fontSize: 24,
                                    color: const Color(0xFFE2E2E2),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B1B1B),
                                    border: Border.all(
                                      color: const Color(0xFF474747),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                focusedPinTheme: PinTheme(
                                  height: 48,
                                  width: 48,
                                  textStyle: GoogleFonts.notoSerif(
                                    fontSize: 24,
                                    color: const Color(0xFFE2E2E2),
                                    fontWeight: FontWeight.w400,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B1B1B),
                                    border: Border.all(
                                      color: const Color(0xFF919191),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onCompleted: (String code) {
                                  _submitCode(context);
                                },
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Timer & Resend
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'EXPIRES IN $_timerText',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFABABAB),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _timerActive
                                      ? null
                                      : () {
                                          setState(() {
                                            _secondsRemaining = 300;
                                            _timerActive = true;
                                          });
                                          _startTimer();
                                          // Resend logic if available
                                        },
                                  child: Container(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Color(0xFF474747),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      'RESEND CODE',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 48),

                            // Verify button
                            GestureDetector(
                              onTap: _isSubmitting || _isVerified
                                  ? null
                                  : () => _submitCode(context),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 24),
                                decoration:
                                    const BoxDecoration(color: Colors.white),
                                child: Center(
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFF1A1C1C),
                                          ),
                                        )
                                      : Text(
                                          'VERIFY NOW',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1A1C1C),
                                            letterSpacing: 2.8,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Verified overlay
              if (_isVerified)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.24,
                        colors: [
                          const Color(0xFF353535),
                          const Color(0xFF131313),
                          const Color(0xFF131313),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Verified!',
                            style: GoogleFonts.notoSerif(
                              fontSize: 36,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: -0.9,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Redirecting to sign in...',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFFC7C6C6),
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
      ),
    );
  }
}
