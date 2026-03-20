import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/widgets/field_error_text.dart';
import '../controller/login/login_bloc.dart';

class SigninForm extends StatefulWidget {
  const SigninForm({super.key});

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginBloc = context.read<LoginBloc>();

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Email field
            BlocBuilder<LoginBloc, LoginModelState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'EMAIL ADDRESS',
                      hintText: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      onChanged: (value) => loginBloc.add(LoginEventUserName(value)),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? "Email is required" : null,
                    ),
                    if (state.state is LoginStateFormError)
                      ErrorText(text: (state.state as LoginStateFormError).errors.email.first),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // Password field
            BlocBuilder<LoginBloc, LoginModelState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField(
                      label: 'PASSWORD',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      obscureText: state.showPassword,
                      autofillHints: const [AutofillHints.password],
                      onChanged: (value) => loginBloc.add(LoginEventPassword(value)),
                      validator: (value) =>
                          (value == null || value.isEmpty) ? "Password is required" : null,
                      suffixIcon: GestureDetector(
                        onTap: () => loginBloc.add(LoginEventShowPassword(state.showPassword)),
                        child: Icon(
                          state.showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: const Color(0xFF919191),
                          size: 20,
                        ),
                      ),
                    ),
                    if (state.state is LoginStateFormError)
                      ErrorText(text: (state.state as LoginStateFormError).errors.password.first),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),

            // Remember me & Forgot password
            BlocBuilder<LoginBloc, LoginModelState>(
              builder: (context, state) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => loginBloc.add(LoginEventActive(state.active)),
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: state.active ? Colors.white : const Color(0xFF474747),
                                width: 1,
                              ),
                              color: state.active ? Colors.white : Colors.transparent,
                            ),
                            child: state.active
                                ? const Icon(Icons.check, size: 12, color: Color(0xFF131313))
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'REMEMBER ME',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF919191),
                              letterSpacing: 0.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/forgotScreen'),
                      child: Text(
                        'FORGOT PASSWORD?',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF919191),
                          letterSpacing: 0.55,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFF919191),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 40),

            // Sign In button
            BlocBuilder<LoginBloc, LoginModelState>(
              builder: (context, state) {
                if (state.state is LoginStateLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                return GestureDetector(
                  onTap: () {
                    if (_formKey.currentState?.validate() ?? true) {
                      TextInput.finishAutofillContext();
                      loginBloc.add(const LoginEventSubmit());
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Center(
                      child: Text(
                        'SIGN IN',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<String>? autofillHints,
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
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  autofillHints: autofillHints,
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