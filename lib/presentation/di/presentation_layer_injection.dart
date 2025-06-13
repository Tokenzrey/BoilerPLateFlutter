import 'package:boilerplate/presentation/di/module/component_widget_module.dart';
import 'package:boilerplate/presentation/di/module/store_module.dart';

class PresentationLayerInjection {
  static Future<void> configurePresentationLayerInjection() async {
    await ComponentWidgetModule.configureComponentWidgetModuleInjection();
    await StoreModule.configureStoreModuleInjection();
  }
}
