import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/router_name.dart';
import '../../utils/utils.dart';
import 'controller/login/login_bloc.dart';
import 'controller/sign_up/sign_up_bloc.dart';
import 'widgets/sign_in_form.dart';
import 'widgets/sign_up_form.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    _pageController = PageController(initialPage: _currentPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: MultiBlocListener(
        listeners: [
          // SUCCESS NAVIGATION LOGIC RESTORED HERE
          BlocListener<LoginBloc, LoginModelState>(
            listenWhen: (previous, current) => previous.state != current.state,
            listener: (context, state) {
              if (state.state is LoginStateError) {
                final status = state.state as LoginStateError;
                Utils.errorSnackBar(context, status.errorMsg);
              } else if (state.state is LoginStateLoaded) {
                // This takes you home on success
                Navigator.pushReplacementNamed(context, RouteNames.mainPage);
              }
            },
          ),
          BlocListener<SignUpBloc, SignUpModelState>(
            listenWhen: (previous, current) => previous.state != current.state,
            listener: (context, state) {
              if (state.state is SignUpStateLoaded) {
                final loadedData = state.state as SignUpStateLoaded;
                Navigator.pushNamed(context, RouteNames.verificationCodeScreen);
                Utils.showSnackBar(context, loadedData.msg);
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 70),
                _buildHeader(),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _buildTabSwitcher(),
                ),
                const SizedBox(height: 32),
                ExpandablePageView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() => _currentPage = page);
                  },
                  children: const [SigninForm(), SignUpForm()],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            _currentPage == 0 ? "Welcome Back" : "Create Account",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 34.0,
              color: Colors.white,
              letterSpacing: -1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _currentPage == 0
                ? "Sign in to access your premium grocery dashboard."
                : "Join OUI for the finest grocery selection.",
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabButton("Sign In", 0),
          _tabButton("Sign Up", 1),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int index) {
    bool isSelected = _currentPage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _pageController.animateToPage(index,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}