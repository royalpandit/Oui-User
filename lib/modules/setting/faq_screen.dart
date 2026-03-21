import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'component/faq_list_widget.dart';
import 'controllers/faq_cubit/faq_cubit.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<FaqCubit>().getFaqList());
  }

  @override
  Widget build(BuildContext context) {
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
              child: BlocBuilder<FaqCubit, FaqCubitState>(
                builder: (context, state) {
                  if (state is FaqCubitStateLoaded) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                      children: [
                        const SizedBox(height: 48),
                        Text(
                          'SUPPORT',
                          style: GoogleFonts.manrope(
                            fontSize: 10, fontWeight: FontWeight.w400,
                            color: Colors.white, height: 1.5, letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Frequently\nAsked',
                          style: GoogleFonts.notoSerif(
                            fontSize: 36, fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFE5E2E1), height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 48),
                        FaqListWidget(faqList: state.faqList),
                      ],
                    );
                  } else if (state is FaqCubitStateLoading) {
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF444444)),
                    );
                  } else if (state is FaqCubitStateError) {
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
