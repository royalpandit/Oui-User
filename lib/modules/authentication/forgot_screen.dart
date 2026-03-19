import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/router_name.dart';
import '../../utils/utils.dart';
import 'controller/forgot_password/forgot_password_cubit.dart';

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ForgotPasswordCubit>();
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordStateLoading) {
          Utils.loadingDialog(context);
        } else {
          Utils.closeDialog(context);
          if (state is ForgotPasswordStateError) {
            Utils.errorSnackBar(context, state.errorMsg);
          } else if (state is ForgotPasswordFormValidate) {
            final emailErrors = state.errors.email;
            Utils.errorSnackBar(context, emailErrors.isNotEmpty ? emailErrors.first : 'Validation error');
          } else if (state is ForgotPasswordStateLoaded) {
            Utils.showSnackBar(context, 'Recovery code sent to ${state.email}');
            Navigator.pushNamed(context, RouteNames.verificationCodeScreen);
          }
        }
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.key_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 32),
              Text(
                "Password Recovery",
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Don't worry, it happens. Enter the email address associated with your account and we will send you a recovery code.",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 48),
              TextFormField(
                style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
                controller: bloc.emailController,
                decoration: InputDecoration(
                  hintText: "Email Address",
                  hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.4), size: 20),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.06),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "We’ll never share your email with anyone else.",
                style: GoogleFonts.inter(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => bloc.forgotPassWord(),
                  child: Text(
                    "Send Recovery Code",
                    style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
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