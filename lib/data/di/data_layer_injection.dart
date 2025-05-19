import 'package:boilerplate/data/di/module/local_module.dart';
import 'package:boilerplate/data/di/module/network_module.dart';
import 'package:boilerplate/data/di/module/repository_module.dart';
import 'package:boilerplate/data/di/module/logger_module.dart';

class DataLayerInjection {
  static Future<void> configureDataLayerInjection() async {
    await LoggerModule.configureLoggingInjection();
    await LocalModule.configureLocalModuleInjection();
    await NetworkModule.configureNetworkModuleInjection();
    await RepositoryModule.configureRepositoryModuleInjection();
  }
}
