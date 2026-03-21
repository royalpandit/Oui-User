import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/widgets/capitalized_word.dart';
import '../../../utils/language_string.dart';
import '../../../utils/utils.dart';
import '../../../widgets/field_error_text.dart';
import '../controllers/contact_us_form_bloc/contact_us_form_bloc.dart';

class ContactUsFormWidget extends StatelessWidget {
  const ContactUsFormWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContactUsFormBloc, ContactUsFormState>(
      listener: (context, state) {
        if (state.status is ContactUsFormStatusError) {
          final status = state.status as ContactUsFormStatusError;
          Utils.errorSnackBar(context, status.errorMessage);
        } else if (state.status is ContactUsFormStatusLoaded) {
          final status = state.status as ContactUsFormStatusLoaded;
          Utils.showSnackBar(context, status.message);
        }
      },
      child: const _FormWidget(),
    );
  }
}

class _FormWidget extends StatelessWidget {
  const _FormWidget();

  @override
  Widget build(BuildContext context) {
    final contactUsFormBloc = context.read<ContactUsFormBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Full Name"),
        _buildTextField(
          context: context,
          hint: Language.name.capitalizeByWord(),
          type: TextInputType.name,
          onChanged: (v) => contactUsFormBloc.add(ContactUsFormNameChange(v)),
          errorSelector: (state) => state.status is ContactUsFormValidateError 
              ? (state.status as ContactUsFormValidateError).errors.name 
              : [],
        ),
        const SizedBox(height: 20),
        
        _buildFieldLabel("Email Address"),
        _buildTextField(
          context: context,
          hint: Language.emailAddress.capitalizeByWord(),
          type: TextInputType.emailAddress,
          onChanged: (v) => contactUsFormBloc.add(ContactUsFormEmailChange(v)),
          errorSelector: (state) => state.status is ContactUsFormValidateError 
              ? (state.status as ContactUsFormValidateError).errors.email 
              : [],
        ),
        const SizedBox(height: 20),

        _buildFieldLabel("Subject"),
        _buildTextField(
          context: context,
          hint: Language.subject.capitalizeByWord(),
          type: TextInputType.text,
          onChanged: (v) => contactUsFormBloc.add(ContactUsFormSubjectChange(v)),
          errorSelector: (state) => state.status is ContactUsFormValidateError 
              ? (state.status as ContactUsFormValidateError).errors.subject 
              : [],
        ),
        const SizedBox(height: 20),

        _buildFieldLabel("Message"),
        _buildTextField(
          context: context,
          hint: Language.message.capitalizeByWord(),
          type: TextInputType.multiline,
          maxLines: 5,
          onChanged: (v) => contactUsFormBloc.add(ContactUsFormMessageChange(v)),
          errorSelector: (state) => state.status is ContactUsFormValidateError 
              ? (state.status as ContactUsFormValidateError).errors.message 
              : [],
        ),
        
        const SizedBox(height: 40),
        
        BlocBuilder<ContactUsFormBloc, ContactUsFormState>(
          builder: (context, state) {
            return state.status is ContactLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF444444)),
                  )
                : GestureDetector(
                    onTap: () {
                      Utils.closeKeyBoard(context);
                      contactUsFormBloc.add(const ContactUsFormSubmit());
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      color: const Color(0xFFE5E2E1),
                      child: Center(
                        child: Text(
                          Language.sendNow.toUpperCase(),
                          style: GoogleFonts.manrope(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: const Color(0xFF131313),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  );
          },
        )
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF777777),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String hint,
    required TextInputType type,
    required Function(String) onChanged,
    required List<String> Function(ContactUsFormState) errorSelector,
    int maxLines = 1,
  }) {
    return BlocBuilder<ContactUsFormBloc, ContactUsFormState>(
      builder: (context, state) {
        final errors = errorSelector(state);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              keyboardType: type,
              onChanged: onChanged,
              maxLines: maxLines,
              style: GoogleFonts.manrope(
                fontSize: 15, fontWeight: FontWeight.w400,
                color: const Color(0xFFE5E2E1),
              ),
              cursorColor: const Color(0xFFE5E2E1),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.manrope(
                  color: const Color(0xFF5E5E5E), fontSize: 14,
                ),
                fillColor: const Color(0xFF1C1B1B),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Color(0x19434842), width: 1),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Color(0xFF444444), width: 1),
                ),
                errorBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide(color: Colors.redAccent, width: 1),
                ),
              ),
            ),
            if (errors.isNotEmpty) ErrorText(text: errors.first),
          ],
        );
      },
    );
  }
}