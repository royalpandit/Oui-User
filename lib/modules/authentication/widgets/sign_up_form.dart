import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildNameField(bloc),
            const SizedBox(height: 20),
            _buildEmailField(bloc),
            const SizedBox(height: 20),
            _buildPhoneField(bloc),
            const SizedBox(height: 20),
            _buildPasswordField(bloc),
            const SizedBox(height: 20),
            _buildConfirmPasswordField(bloc),
            const SizedBox(height: 24),
            _buildTerms(bloc),
            const SizedBox(height: 32),
            _buildFormError(),
            _buildSubmitButton(bloc),
            const SizedBox(height: 20),
            Text(
              'By signing up, you agree to receive personalized updates and offers.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
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
            TextFormField(
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              onChanged: (v) => bloc.add(SignUpEventName(v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              decoration:
                  _premiumInput('Full Name', Icons.person_outline_rounded),
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
            TextFormField(
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              keyboardType: TextInputType.emailAddress,
              onChanged: (v) => bloc.add(SignUpEventEmail(v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Email is required' : null,
              decoration:
                  _premiumInput('Email Address', Icons.alternate_email_rounded),
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
            TextFormField(
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              keyboardType: TextInputType.phone,
              onChanged: (v) => bloc.add(SignUpEventPhone(v)),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Phone is required' : null,
              decoration: _premiumInput('Phone Number', Icons.phone_outlined),
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
            TextFormField(
              obscureText: state.showPassword,
              style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
              onChanged: (v) => bloc.add(SignUpEventPassword(v)),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Password is required' : null,
              decoration:
                  _premiumInput('Secure Password', Icons.lock_outline_rounded)
                      .copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    state.showPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: () =>
                      bloc.add(SignUpEventShowPassword(state.showPassword)),
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
        return TextFormField(
          obscureText: state.showConfirmPassword,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          onChanged: (v) => bloc.add(SignUpEventPasswordConfirm(v)),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Confirm password is required';
            if (v != state.password) return 'Confirm password does not match';
            return null;
          },
          decoration:
              _premiumInput('Confirm Password', Icons.lock_reset_outlined)
                  .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                state.showConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
              onPressed: () => bloc.add(
                  SignUpEventShowConfirmPassword(state.showConfirmPassword)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTerms(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        return Theme(
          data: ThemeData(unselectedWidgetColor: Colors.white.withOpacity(0.4)),
          child: CheckboxListTile(
            value: state.agree == 1,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'I agree to the Terms of Service and Privacy Policy',
              style: GoogleFonts.inter(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            activeColor: Colors.white,
            checkColor: Colors.black,
            dense: true,
            side: BorderSide(color: Colors.white.withOpacity(0.2)),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) => bloc.add(SignUpEventAgree(v! ? 1 : 0)),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        if (state.state is SignUpStateLoading) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        return SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? true) {
                bloc.add(SignUpEventSubmit());
              }
            },
            child: Text(
              'Create My Account',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
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
          return ErrorText(
              text: (state.state as SignUpStateFormError).errorMsg);
        }
        if (state.state is SignUpStateLoadedError) {
          return ErrorText(
              text: (state.state as SignUpStateLoadedError).errorMsg);
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

  InputDecoration _premiumInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
          color: Colors.white.withOpacity(0.25), fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
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
    );
  }
}
