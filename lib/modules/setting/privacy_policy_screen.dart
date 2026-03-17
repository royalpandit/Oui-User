import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import 'controllers/privacy_and_term_condition_cubit/privacy_and_term_condition_cubit.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PrivacyAndTermConditionCubit>().getPrivacyPolicyData();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Language.privacyPolicy.capitalizeByWord(),
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocBuilder<PrivacyAndTermConditionCubit, PrivacyTermConditionCubitState>(
        builder: (context, state) {
          if (state is TermConditionCubitStateLoaded) {
            final data = state.privacyPolicyAndTermConditionModel;
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                data.privacyPolicy.isNotEmpty
                    ? Html(
                        data: data.privacyPolicy,
                        style: {
                          'h1': Style(color: Colors.black, fontSize: FontSize.xLarge),
                          'h2': Style(color: Colors.black87, fontSize: FontSize.large),
                          'p': Style(
                            color: Colors.grey.shade600,
                            textAlign: TextAlign.justify,
                            lineHeight: LineHeight.number(1.6),
                            fontSize: FontSize.medium,
                          ),
                          'ul': Style(color: Colors.grey.shade600),
                          'li': Style(margin: Margins.only(bottom: 4)),
                        },
                      )
                    : Center(
                        child: Text(
                          'No information found',
                          style: GoogleFonts.inter(fontSize: 16, color: Colors.grey.shade400),
                        ),
                      ),
              ],
            );
          } else if (state is TermConditionCubitStateLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is TermConditionCubitStateError) {
            return Center(
              child: Text(state.errorMessage, style: GoogleFonts.inter(color: Colors.red.shade400)),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
