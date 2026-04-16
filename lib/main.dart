import 'dart:async';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/router_name.dart';
import 'state_injector.dart';
import 'utils/k_strings.dart';
import 'utils/my_theme.dart';

bool _crashlyticsReady = false;

Future<void> _initializeFirebaseCrashlytics() async {
  try {
    await Firebase.initializeApp();

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    _crashlyticsReady = true;
  } catch (error, stack) {
    _crashlyticsReady = false;
    debugPrint('Firebase Crashlytics not initialized: $error');
    debugPrintStack(stackTrace: stack);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await runZonedGuarded<Future<void>>(() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    await _initializeFirebaseCrashlytics();
    await StateInjector.init();

    runApp(const MyApp());
  }, (error, stack) async {
    if (_crashlyticsReady) {
      await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return;
    }
    debugPrint('Uncaught zone error: $error');
    debugPrintStack(stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375.0, 812.0),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,
      builder: (BuildContext context, child) {
        return MultiRepositoryProvider(
          providers: StateInjector.repositoryProviders,
          child: MultiBlocProvider(
            providers: StateInjector.blocProviders,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: Kstrings.appName,
              theme: MyTheme.theme,
              // home: const OrderScreen(),
              onGenerateRoute: RouteNames.generateRoute,
              initialRoute: RouteNames.splashScreen,
              onUnknownRoute: (RouteSettings settings) {
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    body: Center(
                        child: Text('No route defined for ${settings.name}')),
                  ),
                );
              },
              builder: (context, child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                );
              },
            ),
          ),
        );
      },
    );
  }
}
