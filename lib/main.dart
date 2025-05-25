import 'dart:async';

import 'package:boilerplate/core/widgets/notification.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/pages/my_app.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await setPreferredOrientations();
  await ServiceLocator.configureDependencies();
  await NotificationService().init(
    onDidReceiveNotificationResponse: (response) {
      debugPrint('Notification tapped! payload: ${response.payload}');
    },
  );

  runApp(
    Provider<GoRouter>(
      create: (_) => AppRouter.router,
      child: MyApp(),
    ),
  );
}

Future<void> setPreferredOrientations() {
  return SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);
}
