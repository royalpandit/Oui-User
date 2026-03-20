import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router_name.dart';
import '../../utils/utils.dart';
import 'controller/login/login_bloc.dart';
import 'controller/sign_up/sign_up_bloc.dart';
import 'widgets/sign_in_form.dart';
import 'widgets/sign_up_form.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int _currentPage = 0; // 0 = Sign In, 1 = Sign Up

  static const _bgColor = Color(0xFF131313);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MultiBlocListener(
        listeners: [
          BlocListener<LoginBloc, LoginModelState>(
            listenWhen: (previous, current) => previous.state != current.state,
            listener: (context, state) {
              if (state.state is LoginStateError) {
                final status = state.state as LoginStateError;
                Utils.errorSnackBar(context, status.errorMsg);
              } else if (state.state is LoginStateLoaded) {
                Navigator.pushReplacementNamed(context, RouteNames.mainPage);
              }
            },
          ),
          BlocListener<SignUpBloc, SignUpModelState>(
            listenWhen: (previous, current) => previous.state != current.state,
            listener: (context, state) {
              if (state.state is SignUpStateLoaded) {
                final loadedData = state.state as SignUpStateLoaded;
                Navigator.pushNamed(context, RouteNames.verificationCodeScreen);
                Utils.showSnackBar(context, loadedData.msg);
              } else if (state.state is SignUpStateLoadedError) {
                final errorData = state.state as SignUpStateLoadedError;
                Utils.errorSnackBar(context, errorData.errorMsg);
              } else if (state.state is SignUpStateFormError) {
                final errorData = state.state as SignUpStateFormError;
                Utils.errorSnackBar(context, errorData.errorMsg);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: _bgColor,
          body: Stack(
            children: [
              // OUI watermark at bottom
              Positioned(
                left: -50,
                bottom: -40,
                right: -50,
                child: Center(
                  child: Text(
                    'OUI',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.notoSerif(
                      fontSize: 280,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.03),
                      height: 1,
                      letterSpacing: -14,
                    ),
                  ),
                ),
              ),

              // Main content
              SafeArea(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: _currentPage == 0
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: _currentPage == 0 ? 80 : 60),
                        // Title
                        Text(
                          _currentPage == 0 ? 'Welcome\nBack' : 'Create Account',
                          textAlign: _currentPage == 0
                              ? TextAlign.left
                              : TextAlign.center,
                          style: GoogleFonts.notoSerif(
                            fontSize: 48,
                            fontWeight: _currentPage == 0
                                ? FontWeight.w300
                                : FontWeight.w400,
                            color: Colors.white,
                            height: 1,
                            letterSpacing: -1.2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _currentPage == 0
                              ? 'SIGN IN TO ACCESS YOUR ACCOUNT'
                              : 'Join OUI for the finest clothing selection.',
                          textAlign: _currentPage == 0
                              ? TextAlign.left
                              : TextAlign.center,
                          style: _currentPage == 0
                              ? GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF919191),
                                  height: 1.5,
                                  letterSpacing: 2.5,
                                )
                              : GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFFC7C6C6),
                                  height: 1.43,
                                  letterSpacing: 0.35,
                                ),
                        ),
                        const SizedBox(height: 48),

                        // Form content
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _currentPage == 0
                              ? const SigninForm()
                              : const SignUpForm(),
                        ),

                        const SizedBox(height: 48),

                        // Toggle Sign In / Sign Up
                        if (_currentPage == 0) ...[
                          // OR divider
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF474747).withOpacity(0.3),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  'OR',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF474747),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: const Color(0xFF474747).withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Continue as Guest
                          GestureDetector(
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context, RouteNames.mainPage, (route) => false),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF474747),
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'CONTINUE AS GUEST',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    letterSpacing: 3.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // New here? Create Account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'NEW HERE? ',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF919191),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _currentPage = 1),
                                child: Text(
                                  'CREATE ACCOUNT',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Terms & Privacy
                          Center(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'BY SIGNING IN, YOU AGREE TO OUR ',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF353535),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'TERMS & CONDITIONS',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.pushNamed(
                                          context,
                                          RouteNames.splashTermsScreen),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF919191),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                      decorationColor: const Color(0xFF919191),
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' &\n',
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF353535),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      height: 1.5,
                                      letterSpacing: 0.9,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'PRIVACY POLICY',
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () => Navigator.pushNamed(
                                          context,
                                          RouteNames.splashPrivacyScreen),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF919191),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w400,
                                      decoration: TextDecoration.underline,
                                      decorationColor: const Color(0xFF919191),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],

                        if (_currentPage == 1) ...[
                          const SizedBox(height: 16),
                          // Already registered? LOG IN
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'ALREADY REGISTERED? ',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF919191),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _currentPage = 0),
                                child: Text(
                                  'LOG IN',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),
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