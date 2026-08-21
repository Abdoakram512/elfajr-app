import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app/service_locator.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase with project options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  await initServiceLocator();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        AppConstants.arabicLocale,
        AppConstants.englishLocale,
      ],
      path: AppConstants.translationsPath,
      fallbackLocale: AppConstants.arabicLocale,
      startLocale: AppConstants.arabicLocale,
      child: const AlFajrApp(),
    ),
  );
}

class AlFajrApp extends StatelessWidget {
  const AlFajrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'مؤسسة الفجر الخيرية',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: AppRouter.router,
          builder: (context, routerChild) {
            return SafeArea(child: routerChild ?? const SizedBox.shrink());
          },
        );
      },
    );
  }
}
