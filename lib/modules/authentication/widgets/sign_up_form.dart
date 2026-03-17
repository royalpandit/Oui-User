import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '/widgets/capitalized_word.dart';
import '/widgets/field_error_text.dart';
import '../../../../utils/constants.dart';
import '../../../utils/language_string.dart';
import '../../../utils/utils.dart';
import '../controller/sign_up/sign_up_bloc.dart';

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
            _buildField(
              hint: "Full Name",
              icon: Icons.person_outline_rounded,
              onChanged: (v) => bloc.add(SignUpEventName(v)),
            ),
            const SizedBox(height: 20),
            _buildField(
              hint: "Email Address",
              icon: Icons.alternate_email_rounded,
              onChanged: (v) => bloc.add(SignUpEventEmail(v)),
            ),
            const SizedBox(height: 20),
            _buildPasswordField(bloc),
            const SizedBox(height: 24),
            _buildTerms(bloc),
            const SizedBox(height: 32),
            _buildSubmitButton(bloc),
            const SizedBox(height: 20),
            Text(
              "By signing up, you agree to receive personalized updates and offers.",
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

  Widget _buildField({required String hint, required IconData icon, required Function(String) onChanged}) {
    return TextFormField(
      style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
      onChanged: onChanged,
      decoration: _premiumInput(hint, icon),
    );
  }

  Widget _buildPasswordField(SignUpBloc bloc) {
    return BlocBuilder<SignUpBloc, SignUpModelState>(
      builder: (context, state) {
        return TextFormField(
          obscureText: state.showPassword,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          onChanged: (v) => bloc.add(SignUpEventPassword(v)),
          decoration: _premiumInput("Secure Password", Icons.lock_outline_rounded).copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                state.showPassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
              onPressed: () => bloc.add(SignUpEventShowPassword(state.showPassword)),
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
              "I agree to the Terms of Service and Privacy Policy",
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
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          if (_formKey.currentState?.validate() ?? true) bloc.add(SignUpEventSubmit());
        },
        child: Text(
          "Create My Account",
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
    );
  }

  InputDecoration _premiumInput(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.25), fontSize: 14),
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