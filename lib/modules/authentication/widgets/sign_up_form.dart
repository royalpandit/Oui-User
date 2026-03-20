import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/router_name.dart';
import '/widgets/field_error_text.dart';
import '../controller/sign_up/sign_up_bloc.dart';
import '../models/auth_error_model.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SignUpBloc>();
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNameField(bloc),
          const SizedBox(height: 40),
          _buildEmailField(bloc),
          const SizedBox(height: 40),
          _buildPhoneField(bloc),
          const SizedBox(height: 40),
          _buildPasswordField(bloc),
          const SizedBox(height: 40),
          _buildConfirmPasswordField(bloc),
          const SizedBox(height: 24),
          _buildTerms(bloc),
          const SizedBox(height: 16),
          _buildFormError(),
          const SizedBox(height: 24),
          _buildSubmitButton(bloc),
        ],
      ),
    );
  }

  Widget _buildNameField(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        final errors = _getErrors(state);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              label: 'FULL NAME',
              hintText: 'John Doe',
              onChanged: (v) => bloc.add(SignUpEventName(v)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            if (errors != null && errors.name.isNotEmpty)
              ErrorText(text: errors.name.first),
          ],
        );
      },
    );
  }

  Widget _buildEmailField(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        final errors = _getErrors(state);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              label: 'EMAIL ADDRESS',
              hintText: 'email@example.com',
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => bloc.add(SignUpEventEmail(v)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Email is required' : null,
            ),
            if (errors != null && errors.email.isNotEmpty)
              ErrorText(text: errors.email.first),
          ],
        );
      },
    );
  }

  Widget _buildPhoneField(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        final errors = _getErrors(state);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              label: 'PHONE NUMBER',
              hintText: '+1 234 567 890',
              keyboardType: TextInputType.phone,
              onChanged: (v) => bloc.add(SignUpEventPhone(v)),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
            ),
            if (errors != null && errors.phone.isNotEmpty)
              ErrorText(text: errors.phone.first),
          ],
        );
      },
    );
  }

  Widget _buildPasswordField(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        final errors = _getErrors(state);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildField(
              label: 'PASSWORD',
              hintText: '••••••••',
              obscureText: state.showPassword,
              onChanged: (v) => bloc.add(SignUpEventPassword(v)),
              validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
              suffixIcon: GestureDetector(
                onTap: () => bloc.add(SignUpEventShowPassword(state.showPassword)),
                child: Icon(
                  state.showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF919191),
                  size: 20,
                ),
              ),
            ),
            if (errors != null && errors.password.isNotEmpty)
              ErrorText(text: errors.password.first),
          ],
        );
      },
    );
  }

  Widget _buildConfirmPasswordField(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        return _buildField(
          label: 'CONFIRM PASSWORD',
          hintText: '••••••••',
          obscureText: state.showConfirmPassword,
          onChanged: (v) => bloc.add(SignUpEventPasswordConfirm(v)),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirm password is required';
            if (v != state.password) return 'Passwords do not match';
            return null;
          },
          suffixIcon: GestureDetector(
            onTap: () => bloc.add(SignUpEventShowConfirmPassword(state.showConfirmPassword)),
            child: Icon(
              state.showConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: const Color(0xFF919191),
              size: 20,
            ),
          ),
        );
      },
    );
  }

  Widget _buildTerms(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => bloc.add(SignUpEventAgree(state.agree == 1 ? 0 : 1)),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.agree == 1 ? Colors.white : const Color(0xFF474747),
                    width: 1,
                  ),
                  color: state.agree == 1 ? Colors.white : Colors.transparent,
                ),
                child: state.agree == 1
                    ? const Icon(Icons.check, size: 14, color: Color(0xFF131313))
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text.rich(
                TextSpan(
                    children: [
                      TextSpan(
                        text: 'I agree to the ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC7C6C6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.63,
                          letterSpacing: 0.3,
                        ),
                      ),
                      TextSpan(
                        text: 'Terms of Service',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamed(
                              context, RouteNames.splashTermsScreen),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' and ',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC7C6C6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.63,
                          letterSpacing: 0.3,
                        ),
                      ),
                      TextSpan(
                        text: 'Privacy Policy',
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamed(
                              context, RouteNames.splashPrivacyScreen),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFC7C6C6),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.63,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

  Widget _buildSubmitButton(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        if (state.state is SignUpStateLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
        return GestureDetector(
          onTap: () {
            if (_formKey.currentState?.validate() ?? true) {
              bloc.add(SignUpEventSubmit());
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Center(
              child: Text(
                'CREATE MY ACCOUNT',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 3.6,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormError() {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        if (state.state is SignUpStateFormError) {
          return ErrorText(text: (state.state as SignUpStateFormError).errorMsg);
        }
        if (state.state is SignUpStateLoadedError) {
          return ErrorText(text: (state.state as SignUpStateLoadedError).errorMsg);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Errors? _getErrors(SignUpModelState state) {
    if (state.state is SignUpStateFormValidateError) {
      return (state.state as SignUpStateFormValidateError).errors;
    }
    return null;
  }

  Widget _buildField({
    required String label,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
    required ValueChanged<String> onChanged,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF474747), width: 1),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF919191),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  onChanged: onChanged,
                  validator: validator,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 16,
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
                    contentPadding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                ),
              ),
              if (suffixIcon != null) suffixIcon,
            ],
          ),
        ],
      ),
    );
  }
}
