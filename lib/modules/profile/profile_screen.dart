import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/modules/profile/controllers/updated_info/updated_info_cubit.dart';
import '/utils/language_string.dart';
import '/utils/utils.dart';
import '/widgets/capitalized_word.dart';
import '../../core/remote_urls.dart';
import '../../core/router_name.dart';
import '../../widgets/please_sign_in_widget.dart';
import '../animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '../authentication/controller/login/login_bloc.dart';
import '../home/controller/cubit/home_controller_cubit.dart';
import 'component/profile_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = context.read<LoginBloc>().userInfo;
    final settingModel = context.read<AppSettingCubit>().settingModel;
    const double appBarHeight = 185; 
    final routeName = ModalRoute.of(context)?.settings.name ?? '';

    if (userData == null) {
      return const PleaseSignInWidget();
    }

    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: appBarHeight,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.black, // Sleek black header
            automaticallyImplyLeading: routeName != RouteNames.mainPage,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: BlocBuilder<UserProfileInfoCubit, UserProfilenfoState>(
                builder: (context, state) {
                  if (state is UpdatedLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (state is UpdatedLoaded) {
                    return ProfileAppBar(
                      height: appBarHeight,
                      logo: RemoteUrls.imageUrl(settingModel?.setting!.logo ?? ''),
                      userUpdateInfo: state.updatedInfo,
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          
          _buildSectionHeader("Account Management"),
          _buildProfileOptions(context),
          
          _buildSectionHeader("Support & Privacy"),
          _buildSupportOptions(context),
          
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
          _buildLogoutButton(context),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 10),
        child: Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  SliverPadding _buildProfileOptions(BuildContext context) {
    final homeModel = context.read<HomeControllerCubit>().homeModel;
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _MenuRow(
            icon: Icons.location_on_outlined,
            title: Language.yourAddress.capitalizeByWord(),
            onTap: () => Navigator.pushNamed(context, RouteNames.addressScreen),
          ),
          _MenuRow(
            icon: Icons.grid_view_rounded,
            title: Language.allCategories.capitalizeByWord(),
            onTap: () => Navigator.pushNamed(context, RouteNames.allCategoryListScreen, arguments: {
              "app_bar": homeModel.sectionTitle[0].custom ?? homeModel.sectionTitle[0].defaultTitle
            }),
          ),
        ]),
      ),
    );
  }

  SliverPadding _buildSupportOptions(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _MenuRow(icon: Icons.description_outlined, title: Language.termsCon.capitalizeByWord(), onTap: () => Navigator.pushNamed(context, RouteNames.termsConditionScreen)),
          _MenuRow(icon: Icons.shield_outlined, title: Language.privacyPolicy.capitalizeByWord(), onTap: () => Navigator.pushNamed(context, RouteNames.privacyPolicyScreen)),
          _MenuRow(icon: Icons.help_outline_rounded, title: Language.faq, onTap: () => Navigator.pushNamed(context, RouteNames.faqScreen)),
          _MenuRow(icon: Icons.info_outline_rounded, title: Language.aboutUs.capitalizeByWord(), onTap: () => Navigator.pushNamed(context, RouteNames.aboutUsScreen)),
          _MenuRow(icon: Icons.mail_outline_rounded, title: Language.contactUs.capitalizeByWord(), onTap: () => Navigator.pushNamed(context, RouteNames.contactUsScreen)),
          _MenuRow(icon: Icons.smartphone_outlined, title: Language.appInfo.capitalizeByWord(), onTap: () => _showAppInfoSheet(context)),
        ]),
      ),
    );
  }



  void _showAppInfoSheet(BuildContext context) {
    context.read<AppSettingCubit>().settingModel;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  Language.appInfo.capitalizeByWord(),
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.black),
                ),
                const SizedBox(height: 20),
                _infoRow(Language.name.capitalizeByWord(), "OUI"),
                _infoRow(Language.version.capitalizeByWord(), "1.3.0"),
                _infoRow("Build", "1"),
                _infoRow("Platform", "Android / iOS"),
                _infoRow(Language.developedBy.capitalizeByWord(), "Corescent"),
                const SizedBox(height: 20),
                Text(
                  "OUI is a premium grocery shopping experience designed to bring the finest selection of products right to your doorstep.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade500)),
          Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: BlocConsumer<LoginBloc, LoginModelState>(
          listener: (context, state) {
            final logout = state.state;
            if (logout is LoginStateLogOutLoading) {
              Utils.loadingDialog(context);
            } else {
              Utils.closeDialog(context);
              if (logout is LoginStateSignOutError) {
                Utils.errorSnackBar(context, logout.errorMsg);
              } else if (logout is LoginStateLogOut) {
                Navigator.pushNamedAndRemoveUntil(context, RouteNames.authenticationScreen, (route) => false);
              }
            }
          },
          builder: (context, state) {
            return OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black12, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.power_settings_new_rounded, color: Colors.black, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    Language.logout.capitalizeByWord(),
                    style: GoogleFonts.inter(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.black12)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, size: 48, color: Colors.black),
            const SizedBox(height: 20),
            Text("Sign Out", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Are you sure you want to end your session?", textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LoginBloc>().add(const LoginEventLogout());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuRow({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black12, width: 1.5),
            ),
            child: Row(
              children: [
                Icon(icon, size: 22, color: Colors.black54),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}