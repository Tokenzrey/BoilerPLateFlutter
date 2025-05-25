import 'dart:async';

import '../../../di/service_locator.dart';
import 'package:boilerplate/core/widgets/notification.dart';

class ComponentWidgetModule {
  static Future<void> configureComponentWidgetModuleInjection() async {
    await _configureNotificationServices();
  }

  static Future<void> _configureNotificationServices() async {
    await NotificationService().init();
    getIt.registerSingleton<NotificationService>(NotificationService());
  }
}
