import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controllers/privacy_and_term_condition_cubit/privacy_and_term_condition_cubit.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<PrivacyAndTermConditionCubit>().getPrivacyPolicyData();
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── App Bar ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(color: Color(0xE5131313)),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: 0.10,
              child: Container(width: double.infinity, height: 1, color: const Color(0xFF1C1B1B)),
            ),

            // ── Body ──
            Expanded(
              child: BlocBuilder<PrivacyAndTermConditionCubit, PrivacyTermConditionCubitState>(
                builder: (context, state) {
                  if (state is TermConditionCubitStateLoaded) {
                    final data = state.privacyPolicyAndTermConditionModel;
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                      children: [
                        const SizedBox(height: 48),
                        Text(
                          'LEGAL DOCUMENTATION',
                          style: GoogleFonts.manrope(
                            fontSize: 10, fontWeight: FontWeight.w400,
                            color: Colors.white, height: 1.5, letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Privacy\nPolicy',
                          style: GoogleFonts.notoSerif(
                            fontSize: 36, fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE5E2E1), height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 48),
                        data.privacyPolicy.isNotEmpty
                            ? Html(
                                data: data.privacyPolicy,
                                style: {
                                  'h1': Style(
                                    color: const Color(0xFFE5E2E1),
                                    fontSize: FontSize.xLarge,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  'h2': Style(
                                    color: const Color(0xFFE5E2E1),
                                    fontSize: FontSize.large,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  'h3': Style(color: const Color(0xFFE5E2E1)),
                                  'p': Style(
                                    color: const Color(0xFFC4C8C0),
                                    textAlign: TextAlign.justify,
                                    lineHeight: LineHeight.number(1.7),
                                    fontSize: FontSize.medium,
                                  ),
                                  'ul': Style(color: const Color(0xFFC4C8C0)),
                                  'li': Style(
                                    color: const Color(0xFFC4C8C0),
                                    margin: Margins.only(bottom: 4),
                                  ),
                                  'a': Style(color: const Color(0xFFE9C349)),
                                  'strong': Style(color: const Color(0xFFE5E2E1)),
                                  'blockquote': Style(
                                    backgroundColor: const Color(0xFF1C1B1B),
                                    padding: HtmlPaddings.all(16),
                                    color: const Color(0xFFC4C8C0),
                                    border: const Border(
                                      left: BorderSide(width: 3, color: Color(0x33E9C349)),
                                    ),
                                  ),
                                },
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 48),
                                  child: Text(
                                    'No information found',
                                    style: GoogleFonts.notoSerif(
                                      fontSize: 16, fontStyle: FontStyle.italic,
                                      color: const Color(0xFF777777),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    );
                  } else if (state is TermConditionCubitStateLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF444444)),
                    );
                  } else if (state is TermConditionCubitStateError) {
                    return Center(
                      child: Text(state.errorMessage, style: GoogleFonts.manrope(color: Colors.red.shade300)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
