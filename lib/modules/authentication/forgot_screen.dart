import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router_name.dart';
import '../../utils/utils.dart';
import 'controller/forgot_password/forgot_password_cubit.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  static const _bgColor = Color(0xFF131313);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ForgotPasswordCubit>();
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordStateError) {
          Utils.errorSnackBar(context, state.errorMsg);
        } else if (state is ForgotPasswordFormValidate) {
          final emailErrors = state.errors.email;
          Utils.errorSnackBar(
            context,
            emailErrors.isNotEmpty ? emailErrors.first : 'Validation error',
          );
        } else if (state is ForgotPasswordStateLoaded) {
          Utils.showSnackBar(
              context, 'Recovery code sent to ${state.email}');
          Navigator.pushNamed(context, RouteNames.setpasswordScreen);
        }
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: _bgColor,
          body: Stack(
            children: [
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
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
                            'OUI',
                            style: GoogleFonts.notoSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(
                            left: 32, right: 32, top: 48, bottom: 96),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password\nRecovery',
                              style: GoogleFonts.notoSerif(
                                fontSize: 36,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                height: 1.11,
                                letterSpacing: -0.9,
                              ),
                            ),
                            const SizedBox(height: 31),
                            Text(
                              'Don\u2019t worry, it happens. Enter the email\naddress associated with your account\nand we will send you a recovery code.',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFFC7C6C6),
                                height: 1.63,
                              ),
                            ),
                            const SizedBox(height: 64),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 4, horizontal: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF474747),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: const Color(0xFF919191)
                                        .withOpacity(0.5),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: bloc.emailController,
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      style: GoogleFonts.manrope(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white,
                                      ),
                                      cursorColor: Colors.white,
                                      decoration: InputDecoration(
                                        hintText: 'Email Address',
                                        hintStyle: GoogleFonts.manrope(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF919191)
                                              .withOpacity(0.5),
                                        ),
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder:
                                            InputBorder.none,
                                        filled: false,
                                        isDense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'WE\u2019LL NEVER SHARE YOUR EMAIL WITH\nANYONE ELSE.',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF919191)
                                    .withOpacity(0.6),
                                height: 1.5,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 48),
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
                            BlocBuilder<ForgotPasswordCubit,
                                ForgotPasswordState>(
                              builder: (context, state) {
                                if (state
                                    is ForgotPasswordStateLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white),
                                  );
                                }
                                return GestureDetector(
                                  onTap: () => bloc.forgotPassWord(),
                                  child: Container(
                                    width: double.infinity,
                                    padding:
                                        const EdgeInsets.symmetric(
                                            vertical: 24),
                                    color: Colors.white,
                                    child: Center(
                                      child: Text(
                                        'SEND RECOVERY CODE',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color:
                                              const Color(0xFF1A1C1C),
                                          letterSpacing: 4.2,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 48),
                            Center(
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'RETURN TO LOGIN',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF919191),
                                    letterSpacing: 2,
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
            ],
          ),
        ),
      ),
    );
  }
}