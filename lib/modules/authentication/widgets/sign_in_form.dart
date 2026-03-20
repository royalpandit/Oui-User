import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/widgets/field_error_text.dart';
import '../controller/login/login_bloc.dart';
import 'guest_button.dart';

class SigninForm extends StatefulWidget {
  const SigninForm({super.key});

  @override
  State<SigninForm> createState() => _SigninFormState();
}

class _SigninFormState extends State<SigninForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loginBloc = context.read<LoginBloc>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            BlocBuilder<LoginBloc, LoginModelState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      initialValue: state.email,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => loginBloc.add(LoginEventUserName(value)),
                      validator: (value) => (value == null || value.isEmpty) ? "Email is required" : null,
                      decoration: _premiumInput("Email Address", Icons.email_outlined),
                    ),
                    if (state.state is LoginStateFormError)
                      ErrorText(text: (state.state as LoginStateFormError).errors.email.first),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            BlocBuilder<LoginBloc, LoginModelState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      obscureText: state.showPassword,
                      initialValue: state.password,
                      onChanged: (value) => loginBloc.add(LoginEventPassword(value)),
                      validator: (value) => (value == null || value.isEmpty) ? "Password is required" : null,
                      decoration: _premiumInput("Password", Icons.lock_outline_rounded).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            state.showPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black.withOpacity(0.45),
                          ),
                          onPressed: () => loginBloc.add(LoginEventShowPassword(state.showPassword)),
                        ),
                      ),
                    ),
                    if (state.state is LoginStateFormError)
                      ErrorText(text: (state.state as LoginStateFormError).errors.password.first),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            _buildRememberMe(loginBloc),
            const SizedBox(height: 32),
            _buildSubmitButton(loginBloc),
            const GuestButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRememberMe(LoginBloc bloc) {
    return BlocBuilder<LoginBloc, LoginModelState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => bloc.add(LoginEventActive(state.active)),
              child: Row(
                children: [
                  Checkbox(
                    value: state.active,
                    activeColor: Colors.black,
                    checkColor: Colors.white,
                    side: BorderSide(color: Colors.black.withOpacity(0.3)),
                    onChanged: (v) => bloc.add(LoginEventActive(state.active)),
                  ),
                  const Text("Remember me", style: TextStyle(color: Colors.black87, fontSize: 13)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/forgotScreen'),
              child: const Text("Forgot Password?", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton(LoginBloc loginBloc) {
    return BlocBuilder<LoginBloc, LoginModelState>(
      builder: (context, state) {
        if (state.state is LoginStateLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? true) {
                loginBloc.add(const LoginEventSubmit());
              }
            },
            child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      },
    );
  }

  InputDecoration _premiumInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
      prefixIcon: Icon(icon, color: Colors.black.withOpacity(0.45), size: 20),
      filled: true,
      fillColor: Colors.black.withOpacity(0.04),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.black),
      ),
    );
  }
}