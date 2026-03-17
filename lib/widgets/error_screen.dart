import 'package:flutter/material.dart';
import 'package:shop_us/widgets/shimmer_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '/core/remote_urls.dart';
import '/modules/animated_splash_screen/controller/app_setting_cubit/app_setting_cubit.dart';
import '/widgets/custom_image.dart';
import '/widgets/shimmer_loader.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appSetting = context.read<AppSettingCubit>();
    final id = appSetting.settingModel!.maintainTextModel!.id;
    print('ID : $id');
    return Scaffold(
      body: BlocBuilder<AppSettingCubit, AppSettingState>(
        builder: (context, state) {
          if (state is AppSettingStateLoading) {
            return const Center(
                child: SizedBox(
                    height: 28,
                    width: 120,
                    child: ShimmerLoader.rect(height: 12, width: 120)));
          } else if (state is AppSettingStateError) {
            return Center(child: Text(state.meg));
          } else if (state is AppSettingStateLoaded) {
            final result = state.settingModel.maintainTextModel;
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImage(path: RemoteUrls.imageUrl(result!.image)),
                  const SizedBox(height: 20.0),
                  Text(
                    result.description,
                    style: GoogleFonts.jost(fontSize: 18.0, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
