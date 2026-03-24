import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

import '/core/router_name.dart';
import '../authentication/controller/login/login_bloc.dart';
import 'controller/app_setting_cubit/app_setting_cubit.dart';
import 'widgets/setting_error_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Pre-request camera and microphone permissions so try-on screens
  /// don't need to show permission dialogs mid-experience.
  /// Note: Photo/gallery permissions are requested only when actually needed
  /// (in try-on gallery screen) to avoid triggering the photo picker UI.
  Future<void> _requestPermissions() async {
    final perms = <Permission>[
      Permission.camera,
      Permission.microphone,
    ];
    await perms.request();
  }

  @override
  Widget build(BuildContext context) {
    final appSettingCubit = context.read<AppSettingCubit>();
    final loginBloc = context.read<LoginBloc>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: BlocConsumer<AppSettingCubit, AppSettingState>(
          builder: (BuildContext context, state) {
            if (state is AppSettingStateError) {
              return SettingErrorWidget(message: state.meg);
            }
            return _buildBodyComponent();
          },
          listener: (context, state) async {
            log("listener $state", name: 'Splash Screen');
            if (state is AppSettingStateLoaded) {
              // Request permissions before navigating away
              await _requestPermissions();
              if (!mounted) return;

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

  Widget _buildBodyComponent() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background image with reduced opacity
        Opacity(
          opacity: 0.45,
          child: Image.asset(
            'assets/icons/splashs.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        // Dark overlay
        Container(
          color: Colors.black.withValues(alpha: 0.35),
        ),
        // Content
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'OUI',
                style: GoogleFonts.notoSerif(
                  fontSize: 72.0,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 48,
                height: 1,
                color: Colors.grey,
              ),
              const SizedBox(height: 20),
              Text(
                'THE PREMIUM STORE',
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 3.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}