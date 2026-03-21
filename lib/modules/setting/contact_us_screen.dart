import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import 'component/contact_us_form_widget.dart';
import 'controllers/contact_us_cubit/contact_us_cubit.dart';
import 'model/contact_us_mode.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  void initState() {
    Future.microtask(() => context.read<ContactUsCubit>().getContactUsContent());
    super.initState();
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
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                children: [
                  const SizedBox(height: 48),
                  Text(
                    'CONCIERGE',
                    style: GoogleFonts.manrope(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: Colors.white, height: 1.5, letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Contact\nCurator',
                    style: GoogleFonts.notoSerif(
                      fontSize: 36, fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFE5E2E1), height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Reach out to our dedicated team.\nWe\'re here to assist you with any inquiry.',
                    style: GoogleFonts.manrope(
                      fontSize: 16, fontWeight: FontWeight.w300,
                      color: const Color(0xFFC4C8C0), height: 1.63,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // ── Contact info ──
                  const ContactUsContentWidget(),
                  const SizedBox(height: 48),

                  // ── Form ──
                  Text(
                    'SEND A MESSAGE',
                    style: GoogleFonts.manrope(
                      fontSize: 10, fontWeight: FontWeight.w400,
                      color: Colors.white, height: 1.5, letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const ContactUsFormWidget(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ContactUsContentWidget extends StatelessWidget {
  const ContactUsContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ContactUsCubit, ContactUsState>(
      builder: (context, state) {
        if (state is ContactUsStateLoaded) {
          return _buildInfoColumn(context, state.contactUsModel);
        } else if (state is ContactUsStateLoading) {
          return const Center(
            child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF444444)),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildInfoColumn(BuildContext context, ContactUsModel data) {
    return Column(
      children: [
        _buildInfoRow(Icons.email_outlined, Language.emailAddress, data.email),
        _buildInfoRow(Icons.phone_outlined, Language.phoneNumber, data.phone),
        _buildInfoRow(Icons.location_on_outlined, Language.address, data.address),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1, color: const Color(0xFF434842).withOpacity(0.12)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF777777), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.capitalizeByWord(),
                  style: GoogleFonts.manrope(
                    fontSize: 10, fontWeight: FontWeight.w400,
                    color: const Color(0xFF777777), height: 1.5,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w400,
                    color: const Color(0xFFE5E2E1), height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}