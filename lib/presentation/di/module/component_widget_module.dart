import 'dart:async';

import 'package:flutter/material.dart';

import '../../../di/service_locator.dart';
import 'package:boilerplate/core/widgets/notification.dart';

class ComponentWidgetModule {
  static Future<void> configureComponentWidgetModuleInjection() async {
    await _configureNotificationServices();
  }

  static Future<void> _configureNotificationServices() async {
    final notificationService = NotificationService();
    await notificationService.init(
      requestPermissions: true,
      logLevel: NotificationLogLevel.verbose,
      defaultIcon: 'ic_appicon',
      onDidReceiveNotificationResponse: (response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
    getIt.registerSingleton<NotificationService>(notificationService);
  }
}
