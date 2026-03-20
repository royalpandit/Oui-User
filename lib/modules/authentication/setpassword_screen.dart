import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

import '../../core/router_name.dart';
import '../../utils/utils.dart';
import 'controller/forgot_password/forgot_password_cubit.dart';

class SetpasswordScreen extends StatefulWidget {
  const SetpasswordScreen({super.key});

  @override
  State<SetpasswordScreen> createState() => _SetpasswordScreenState();
}

class _SetpasswordScreenState extends State<SetpasswordScreen> {
  static const _bgColor = Color(0xFF131313);

  int _page = 0; // 0 = recovery code, 1 = new password
  bool _passwordVisible = false;
  bool _passwordVisible2 = false;

  // Timer
  Timer? _timer;
  int _remainingSeconds = 299; // 4:59

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 299;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ForgotPasswordCubit>();
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordStateError) {
          Utils.errorSnackBar(context, state.errorMsg);
        } else if (state is PasswordSetStateLoaded) {
          Utils.showSnackBar(context, state.message);
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteNames.authenticationScreen,
            (route) => false,
          );
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bgColor,
          body: Stack(
            children: [
              // Right-side subtle panel
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 130,
                child: Container(
                  color: const Color(0xFF1B1B1B).withOpacity(0.2),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    // App bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_page == 1) {
                                setState(() => _page = 0);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _page == 0 ? 'RECOVERY' : 'RESET PASSWORD',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: 4,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    // Body
                    Expanded(
                      child: _page == 0
                          ? _buildRecoveryCodePage(bloc)
                          : _buildNewPasswordPage(bloc),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Page 0: Enter Recovery Code ──────────────────────────

  Widget _buildRecoveryCodePage(ForgotPasswordCubit bloc) {
    final defaultTheme = PinTheme(
      width: 48,
      height: 64,
      textStyle: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        border: Border.all(color: const Color(0xFF919191)),
      ),
    );

    final focusedTheme = defaultTheme.copyDecorationWith(
      border: Border.all(color: Colors.white, width: 1.5),
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(left: 32, right: 32, top: 64, bottom: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Enter\nRecovery Code',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSerif(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.11,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Enter the 6-digit code sent to your email.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFC7C6C6),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 64),
          Pinput(
            length: 6,
            defaultPinTheme: defaultTheme,
            focusedPinTheme: focusedTheme,
            submittedPinTheme: defaultTheme,
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (value) {
              bloc.codeController.text = value;
              log('code: $value');
            },
            onCompleted: (value) {
              log('code complete: $value');
            },
          ),
          const SizedBox(height: 32),
          // Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.access_time_rounded,
                size: 16,
                color: const Color(0xFFABABAB).withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'EXPIRES IN $_timerText',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFFABABAB),
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 64),
          // Verify Code button
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            builder: (context, state) {
              if (state is ForgotPasswordStateLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              return GestureDetector(
                onTap: () {
                  if (bloc.codeController.text.length == 6) {
                    setState(() => _page = 1);
                  } else {
                    Utils.errorSnackBar(
                        context, 'Please enter the full 6-digit code');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'VERIFY CODE',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1C1C),
                        letterSpacing: 4.2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          // Resend code
          GestureDetector(
            onTap: () {
              _startTimer();
              Utils.showSnackBar(context, 'Recovery code resent');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF474747)),
              ),
              child: Text(
                'RESEND CODE',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF919191),
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 64),
          // Copyright
          Opacity(
            opacity: 0.2,
            child: Container(
              width: double.infinity,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00474747),
                    Color(0xFF474747),
                    Color(0x00474747),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '\u00A9 2025 OUI \u2014 THE PREMIUM STORE',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF919191).withOpacity(0.4),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Page 1: Create New Password ─────────────────────────

  Widget _buildNewPasswordPage(ForgotPasswordCubit bloc) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.only(left: 32, right: 32, top: 48, bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New\nPassword',
            style: GoogleFonts.notoSerif(
              fontSize: 36,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              height: 1.11,
              letterSpacing: -0.9,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your new password must be different\nfrom previously used passwords.',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFC7C6C6),
              height: 1.63,
            ),
          ),
          const SizedBox(height: 64),
          // New password
          Text(
            'NEW PASSWORD',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF919191),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF919191)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: bloc.paswordController,
                    obscureText: !_passwordVisible,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF353535),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  child: Icon(
                    _passwordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF919191),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Confirm password
          Text(
            'CONFIRM NEW PASSWORD',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF919191),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF919191)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: bloc.paswordConfirmController,
                    obscureText: !_passwordVisible2,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Confirm new password',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF353535),
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _passwordVisible2 = !_passwordVisible2),
                  child: Icon(
                    _passwordVisible2
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: const Color(0xFF919191),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 64),
          // Gradient divider
          Opacity(
            opacity: 0.2,
            child: Container(
              width: double.infinity,
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0x00474747),
                    Color(0xFF474747),
                    Color(0x00474747),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Reset Password button
          BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
            builder: (context, state) {
              if (state is ForgotPasswordStateLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              return GestureDetector(
                onTap: () => bloc.setNewPassword(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      'RESET PASSWORD',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1C1C),
                        letterSpacing: 4.2,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}