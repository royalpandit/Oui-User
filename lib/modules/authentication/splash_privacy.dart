import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../modules/setting/controllers/privacy_and_term_condition_cubit/privacy_and_term_condition_cubit.dart';

class SplashPrivacyScreen extends StatelessWidget {
  const SplashPrivacyScreen({super.key});

  static const _bgColor = Color(0xFF131313);

  @override
  Widget build(BuildContext context) {
    context.read<PrivacyAndTermConditionCubit>().getPrivacyPolicyData();
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'PRIVACY POLICY',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white,
            letterSpacing: 3.0,
          ),
        ),
      ),
      body: BlocBuilder<PrivacyAndTermConditionCubit,
          PrivacyTermConditionCubitState>(
        builder: (context, state) {
          if (state is TermConditionCubitStateLoaded) {
            final data = state.privacyPolicyAndTermConditionModel;
            return ListView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              children: [
                data.privacyPolicy.isNotEmpty
                    ? Html(
                        data: data.privacyPolicy,
                        style: {
                          'h1': Style(
                            color: Colors.white,
                            fontSize: FontSize.xLarge,
                            fontFamily: GoogleFonts.notoSerif().fontFamily,
                          ),
                          'h2': Style(
                            color: Colors.white.withOpacity(0.87),
                            fontSize: FontSize.large,
                            fontFamily: GoogleFonts.notoSerif().fontFamily,
                          ),
                          'h3': Style(
                            color: Colors.white.withOpacity(0.87),
                            fontFamily: GoogleFonts.notoSerif().fontFamily,
                          ),
                          'p': Style(
                            color: const Color(0xFFC7C6C6),
                            textAlign: TextAlign.justify,
                            lineHeight: LineHeight.number(1.6),
                            fontSize: FontSize.medium,
                            fontFamily: GoogleFonts.manrope().fontFamily,
                          ),
                          'ul': Style(color: const Color(0xFFC7C6C6)),
                          'li': Style(
                            color: const Color(0xFFC7C6C6),
                            margin: Margins.only(bottom: 4),
                          ),
                          'a': Style(
                            color: const Color(0xFF919191),
                            textDecoration: TextDecoration.underline,
                          ),
                          'body': Style(
                            color: const Color(0xFFC7C6C6),
                          ),
                        },
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 100),
                          child: Text(
                            'No information found',
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF919191)),
                          ),
                        ),
                      ),
              ],
            );
          } else if (state is TermConditionCubitStateLoading) {
            return _buildSkeleton();
          } else if (state is TermConditionCubitStateError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  state.errorMessage,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                      color: const Color(0xFF919191), fontSize: 14),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1B1B1B),
      highlightColor: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 24, width: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 24),
            ...List.generate(3, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            )),
            Container(height: 14, width: 240, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 32),
            Container(height: 20, width: 160, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            ...List.generate(4, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            )),
            Container(height: 14, width: 180, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 32),
            Container(height: 20, width: 220, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            const SizedBox(height: 16),
            ...List.generate(5, (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(height: 14, width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
            )),
          ],
        ),
      ),
    );
  }
}
