import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'configs/dio_configs.dart';
import 'configs/environment.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/connectivity_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/cache_interceptor.dart';
import 'interceptors/auth_interceptor.dart';
// Import with alias to resolve ambiguous import
import 'network_constants.dart' as dio_constants;
import '../dio_client.dart';

/// Builder for creating and configuring Dio HTTP client instances
class DioClientBuilder {
  final Dio _dio = Dio();
  final DioConfigs _configs;

  /// Creates a new DioClientBuilder with the specified configuration
  DioClientBuilder({
    required DioConfigs configs,
  }) : _configs = configs {
    _configureBaseOptions();
  }

  /// Creates a DioClientBuilder with default configuration for the specified environment
  factory DioClientBuilder.forEnvironment(Environment environment) {
    return DioClientBuilder(
      configs: DioConfigs(
        baseUrl: environment.apiBaseUrl,
        connectTimeout: environment.apiTimeoutMs,
        receiveTimeout: environment.apiTimeoutMs,
        sendTimeout: environment.apiTimeoutMs,
      ),
    );
  }

  /// Configures base options for the Dio instance
  void _configureBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: _configs.baseUrl,
      connectTimeout: Duration(milliseconds: _configs.connectTimeout),
      receiveTimeout: Duration(milliseconds: _configs.receiveTimeout),
      sendTimeout: Duration(milliseconds: _configs.sendTimeout),
      headers: {
        dio_constants.NetworkConstants.headers.accept:
            dio_constants.NetworkConstants.contentType.json,
        dio_constants.NetworkConstants.headers.contentType:
            dio_constants.NetworkConstants.contentType.json,
      }..addAll(_configs.headers ?? {}),
    );
  }

  /// Adds logging interceptor (debug mode only)
  DioClientBuilder withLogging({Level level = Level.body}) {
    if (kDebugMode) {
      _dio.interceptors.add(getIt<LoggingInterceptor>());
    }
    return this;
  }

  /// Adds connectivity checking interceptor
  DioClientBuilder withConnectivity(ConnectivityService connectivityService) {
    _dio.interceptors.add(ConnectivityInterceptor(connectivityService));
    return this;
  }

  /// Adds retry capability with configurable options
  DioClientBuilder withRetry({
    int? retries,
    int? intervalMs,
    bool useExponentialBackoff = true,
  }) {
    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      options: RetryOptions(
        retries: retries ?? dio_constants.NetworkConstants.retry.defaultRetries,
        retryInterval: Duration(
            milliseconds: intervalMs ??
                dio_constants.NetworkConstants.retry.defaultIntervalMs),
        useExponentialBackoff: useExponentialBackoff,
      ),
    ));
    return this;
  }

  /// Adds authentication interceptor
  DioClientBuilder withAuth(
    AuthTokenService tokenService, {
    bool retryWithRefresh = true,
    bool logoutOnAuthError = false,
  }) {
    _dio.interceptors.add(AuthInterceptor(
      tokenService,
      _dio,
      defaultAuthOptions: AuthOptions(
        retryWithRefresh: retryWithRefresh,
        logoutOnAuthError: logoutOnAuthError,
      ),
    ));
    return this;
  }

  /// Adds response caching interceptor
  DioClientBuilder withCache(
    CacheStore cacheStore, {
    bool cacheGet = true,
    Duration defaultDuration = const Duration(minutes: 5),
  }) {
    _dio.interceptors.add(CacheInterceptor(
      cacheStore,
      defaultOptions: CacheOptions(
        cacheGet: cacheGet,
        defaultDuration: defaultDuration,
      ),
    ));
    return this;
  }

  /// Adds error handling interceptor
  DioClientBuilder withErrorHandler({
    Map<int, String Function(Response)>? statusCodeErrorMessages,
  }) {
    _dio.interceptors.add(ErrorInterceptor(
      statusCodeErrorMessages: statusCodeErrorMessages,
    ));
    return this;
  }

  /// Adds a custom interceptor
  DioClientBuilder withInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
    return this;
  }

  /// Adds multiple interceptors at once
  DioClientBuilder withInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
    return this;
  }

  /// Sets default timeout values
  DioClientBuilder withTimeouts({
    int? connectTimeoutMs,
    int? receiveTimeoutMs,
    int? sendTimeoutMs,
  }) {
    if (connectTimeoutMs != null) {
      _dio.options.connectTimeout = Duration(milliseconds: connectTimeoutMs);
    }
    if (receiveTimeoutMs != null) {
      _dio.options.receiveTimeout = Duration(milliseconds: receiveTimeoutMs);
    }
    if (sendTimeoutMs != null) {
      _dio.options.sendTimeout = Duration(milliseconds: sendTimeoutMs);
    }
    return this;
  }

  /// Adds default headers to all requests
  DioClientBuilder withDefaultHeaders(Map<String, String> headers) {
    headers.forEach((key, value) {
      _dio.options.headers[key] = value;
    });
    return this;
  }

  /// Builds the configured Dio client
  Dio build() => _dio;

  /// Builds a DioClient wrapper around the configured Dio instance
  DioClient buildClient() => DioClient(_dio, _configs, getIt<Logger>());
}
