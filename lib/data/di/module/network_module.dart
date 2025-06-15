import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/data/network/dio/configs/dio_configs.dart';
import 'package:boilerplate/data/network/dio/configs/environment.dart';
import 'package:boilerplate/data/network/dio_client.dart';
import 'package:boilerplate/data/network/dio/dio_client_builder.dart';
// import 'package:boilerplate/core/data/network/dio/interceptors/auth_interceptor.dart'
//     as dio_auth;
// import 'package:boilerplate/core/data/network/dio/interceptors/auth_interceptor.dart';
import 'package:boilerplate/data/network/dio/interceptors/cache_interceptor.dart';
import 'package:boilerplate/data/network/dio/interceptors/connectivity_interceptor.dart';
import 'package:boilerplate/data/network/dio/interceptors/error_interceptor.dart'
    as dio_error;
import 'package:boilerplate/data/network/dio/interceptors/logging_interceptor.dart';
import 'package:boilerplate/data/network/interceptors/error_interceptor.dart';
import 'package:boilerplate/data/network/rest_client.dart';
// import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boilerplate/core/data/network/firebase/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../di/service_locator.dart';

class NetworkModule {
  static Future<void> configureNetworkModuleInjection() async {
    await _configureEventBus();
    await _configureInterceptors();
    await _configureFirebase();
    await _configureRestClient();
    await _configureDioClient();
    await _configureApis();
  }

  static Future<void> _configureFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    getIt.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

    getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  }

  static Future<void> _configureEventBus() async {
    getIt.registerSingleton<EventBus>(EventBus());
  }

  static Future<void> _configureInterceptors() async {
    // Register existing interceptors
    getIt.registerSingleton<LoggingInterceptor>(
      LoggingInterceptor(
        baseLogger: getIt<Logger>(),
        level: Level.body,
        compact: false,
      ),
    );
    getIt.registerSingleton<ErrorInterceptor>(ErrorInterceptor(getIt()));
    // getIt.registerSingleton<AuthInterceptor>(
    //   AuthInterceptor(
    //     accessToken: () async =>
    //         await getIt<SharedPreferenceHelper>().authToken,
    //   ),
    // );

    // Register our new interceptors
    getIt.registerSingleton<dio_error.ErrorInterceptor>(
        dio_error.ErrorInterceptor());

    // Register auth token service adapter for our AuthInterceptor
    // getIt.registerSingleton<dio_auth.AuthTokenService>(
    //   _SharedPrefAuthTokenService(getIt<SharedPreferenceHelper>()),
    // );

    // Register connectivity service
    getIt.registerSingleton<ConnectivityService>(
      _DefaultConnectivityService(),
    );

    // Register cache store
    getIt.registerSingleton<CacheStore>(
      SharedPrefsCacheStore(
        getIt<SharedPreferences>(),
        keyPrefix: 'network_cache_', // Use a unique prefix
        maxEntries: 100, // Limit to 100 cache entries
        maxAgeMs: 3 * 24 * 60 * 60 * 1000, // Max age of 3 days
      ),
    );
  }

  static Future<void> _configureRestClient() async {
    getIt.registerSingleton(RestClient());
  }

  static Future<void> _configureDioClient() async {
    // Environment initialization should ideally be done at app startup,
    // but keeping it here for consistency with your code
    Environment.init(environmentType: EnvironmentType.production);

    final dioConfigs = DioConfigs(
      baseUrl: Environment.current.apiBaseUrl,
      connectTimeout: Environment.current.apiTimeoutMs,
      receiveTimeout: Environment.current.apiTimeoutMs,
      sendTimeout: Environment.current.apiTimeoutMs,
    );

    // Register DioConfigs
    getIt.registerSingleton<DioConfigs>(dioConfigs);

    // Create and configure the Dio instance using DioClientBuilder
    final dio = DioClientBuilder(configs: dioConfigs)
        .withLogging(
            level: Environment.current.enableLogging ? Level.body : Level.none)
        .withErrorHandler()
        .withConnectivity(getIt<ConnectivityService>())
        .withRetry(
          retries: 3,
          intervalMs: 1000,
          useExponentialBackoff: true,
        )
        .withCache(
          getIt<CacheStore>(),
          cacheGet: true,
          defaultDuration: const Duration(hours: 1),
        )
        .withDefaultHeaders({
      'X-App-Platform': 'flutter',
      'X-App-Version': '1.0.0',
    }).build();

    // Register the configured Dio instance
    getIt.registerSingleton<Dio>(dio);

    // Register DioClient
    getIt.registerSingleton<DioClient>(
      DioClient(dio, dioConfigs, getIt<Logger>()),
    );
  }

  static Future<void> _configureApis() async {
    // Register your API services here
    getIt.registerSingleton<TopApiService>(
      TopApiService(getIt<DioClient>()),
    );
    getIt.registerSingleton<ChapterApiService>(
      ChapterApiService(getIt<DioClient>()),
    );
  }
}

/// Adapter to connect SharedPreferenceHelper to our AuthTokenService
// class _SharedPrefAuthTokenService implements dio_auth.AuthTokenService {
//   final SharedPreferenceHelper _preferences;

//   _SharedPrefAuthTokenService(this._preferences);

//   @override
//   Future<String?> getAccessToken() async {
//     return _preferences.authToken;
//   }

//   @override
//   Future<String?> refreshAccessToken() async {
//     // Implement your token refresh logic here
//     // This might involve calling an API endpoint to refresh the token
//     return _preferences.authToken;
//   }

//   @override
//   Future<bool> isTokenExpired() async {
//     // Implement token expiration check logic
//     // You might want to check a stored expiration time
//     return false;
//   }

//   @override
//   Future<void> logout() async {
//     await _preferences.removeAuthToken();
//   }
// }

/// Simple connectivity service implementation
class _DefaultConnectivityService implements ConnectivityService {
  @override
  Future<bool> isConnected() async {
    // In a real implementation, you would check actual network connectivity
    // For now, we assume connectivity is available
    return true;
  }

  @override
  Stream<bool>? get onConnectivityChanged => null;
}
