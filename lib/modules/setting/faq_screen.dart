import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/language_string.dart';
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
          Language.faq,
          style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: BlocBuilder<FaqCubit, FaqCubitState>(
        builder: (context, state) {
          if (state is FaqCubitStateLoaded) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                FaqListWidget(faqList: state.faqList),
              ],
            );
          } else if (state is FaqCubitStateLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          } else if (state is FaqCubitStateError) {
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
