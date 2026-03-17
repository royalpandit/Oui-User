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
          Language.contactUs.capitalizeByWord(),
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ContactUsFormWidget(),
            const SizedBox(height: 40),
            const ContactUsContentWidget(),
            const SizedBox(height: 40),
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
          return _buildInfoGrid(context, state.contactUsModel);
        } else if (state is ContactUsStateLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildInfoGrid(BuildContext context, ContactUsModel data) {
    return Column(
      children: [
        _buildInfoCard(context, Icons.email_outlined, Language.emailAddress, data.email),
        _buildInfoCard(context, Icons.phone_outlined, Language.phoneNumber, data.phone),
        _buildInfoCard(context, Icons.location_on_outlined, Language.address, data.address),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, IconData icon, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.capitalizeByWord(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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