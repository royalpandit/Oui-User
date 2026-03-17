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
        const SizedBox(height: 16),
        
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
        const SizedBox(height: 16),

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
        const SizedBox(height: 16),

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
        
        const SizedBox(height: 32),
        
        BlocBuilder<ContactUsFormBloc, ContactUsFormState>(
          builder: (context, state) {
            return state.status is ContactLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.black))
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Utils.closeKeyBoard(context);
                        contactUsFormBloc.add(const ContactUsFormSubmit());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        Language.sendNow.toUpperCase(),
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1),
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
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.black,
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
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(color: Colors.grey.shade400, fontSize: 14),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent, width: 1),
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