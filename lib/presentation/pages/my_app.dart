import 'package:boilerplate/constants/app_theme.dart';
import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/components/overlay/toast.dart';
import 'package:boilerplate/presentation/store/language/language_store.dart';
import 'package:boilerplate/presentation/store/theme/theme_store.dart';
import 'package:boilerplate/utils/locale/app_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../di/service_locator.dart';

class MyApp extends StatelessWidget {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final LanguageStore _languageStore = getIt<LanguageStore>();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = Provider.of<GoRouter>(context);

    // Konfigurasi Toast
    ToastConfig.configure(
      defaultPosition: ToastPosition.bottomRight,
      maxVisibleToasts: 3,
      defaultDuration: const Duration(seconds: 4),
      spacing: 8,
      padding: const EdgeInsets.all(16),
    );

    return Observer(
      builder: (context) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: _themeStore.darkMode
              ? AppThemeData.darkThemeData
              : AppThemeData.lightThemeData,
          routerDelegate: router.routerDelegate,
          routeInformationParser: router.routeInformationParser,
          routeInformationProvider: router.routeInformationProvider,
          backButtonDispatcher: router.backButtonDispatcher,
          locale: Locale(_languageStore.locale),
          supportedLocales: _languageStore.supportedLanguages
              .map((language) => Locale(language.locale, language.code))
              .toList(),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            return OverlayManagerLayer(
              popoverHandler: const PopoverOverlayHandler(),
              menuHandler: const PopoverOverlayHandler(),
              toastHandler: ToastOverlayHandler(),
              drawerHandler: DrawerOverlayHandler(),
              child: child ?? const SizedBox(),
            );
          },
        );
      },
    );
  }
}
