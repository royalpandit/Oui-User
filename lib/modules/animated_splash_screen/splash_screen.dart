import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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

  Widget _buildBodyComponent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icons/ouibg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'OUI',
              style: GoogleFonts.notoSerif(
                fontSize: 48.0,
                fontWeight: FontWeight.w700,
                letterSpacing: 8.0,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 1,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
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
    );
  }
}