import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/router_name.dart';
import '/widgets/custom_image.dart';
import '../authentication/controller/login/login_bloc.dart';
import 'controller/app_setting_cubit/app_setting_cubit.dart';
import 'widgets/setting_error_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final appSettingCubit = context.read<AppSettingCubit>();
    final loginBloc = context.read<LoginBloc>();

    // Premium iOS Black aesthetic
    const Color bgBlack = Color(0xFF000000);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light, // Forces white status bar icons
      child: Scaffold(
        backgroundColor: bgBlack,
        body: BlocConsumer<AppSettingCubit, AppSettingState>(
          builder: (BuildContext context, state) {
            if (state is AppSettingStateError) {
              return SettingErrorWidget(message: state.meg);
            }
            return _buildBodyComponent(size);
          },
          listener: (context, state) {
            log("listener $state", name: 'Splash Screen');
            if (state is AppSettingStateLoaded) {
              if (state.settingModel.maintainTextModel!.status == 0) {
                if (loginBloc.isLogedIn) {
                  Navigator.pushReplacementNamed(context, RouteNames.mainPage);
                } else if (appSettingCubit.isOnBoardingShown) {
                  Navigator.pushReplacementNamed(
                      context, RouteNames.authenticationScreen);
                } else {
                  Navigator.pushReplacementNamed(
                      context, RouteNames.onBoardingScreen);
                }
              } else {
                Navigator.pushReplacementNamed(context, RouteNames.errorScreen);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildBodyComponent(Size size) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Stack(
        children: [
          // Main Logo - Using assets\icon\login.png via KImages.logo
          Center(
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 1200),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, double value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value), // Smooth grow from 0.8 to 1.0
                    child: CustomImage(
                      path: 'assets/icon/login.png', // Explicitly using the requested path
                      width: size.width * 0.45, // Slightly smaller for premium minimalist look
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Clean, Professional Footer Branding
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0), // Increased padding for iOS look
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // App Title
                  Text(
                    'OUI',
                    style: GoogleFonts.inter(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 6.0, // Wider tracking for premium feel
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // App Tagline
                  Text(
                    'PREMIUM GROCERY EXPERIENCE',
                    style: GoogleFonts.inter(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2.0,
                      color: Colors.white.withOpacity(0.4), // Muted grey-white
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Subtle Progress Indicator
                  SizedBox(
                    width: 40,
                    height: 1.5,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white24),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}