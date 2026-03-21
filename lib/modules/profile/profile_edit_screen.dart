import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/utils/language_string.dart';
import '/widgets/capitalized_word.dart';
import 'component/profile_edit_form.dart';
import 'controllers/updated_info/updated_info_cubit.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          Language.editProfile.capitalizeByWord(),
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFFE5E2E1)),
        ),
      ),
      body: BlocBuilder<UserProfileInfoCubit, UserProfilenfoState>(
        builder: (context, state) {
          if (state is UpdatedLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFE5E2E1)));
          }
          if (state is UpdatedError) {
            return Center(child: Text(state.message, style: GoogleFonts.manrope(color: Colors.red.shade400)));
          } else if (state is UpdatedLoaded) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: ProfileEditForm(
                userData: state.updatedInfo,
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
