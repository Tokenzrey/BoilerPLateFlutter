import 'package:dio/dio.dart';
import 'dio_configs.dart';
import 'environment.dart';

/// Factory for creating Dio BaseOptions based on environment
class DioBaseOptions {
  /// Creates default BaseOptions object
  static BaseOptions createDefaultOptions() {
    return BaseOptions(
      baseUrl: Environment.current.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: _kDefaultConnectTimeout),
      receiveTimeout: const Duration(milliseconds: _kDefaultReceiveTimeout),
      sendTimeout: const Duration(milliseconds: _kDefaultSendTimeout),
      headers: _defaultHeaders,
      validateStatus: (status) {
        return status != null && status >= 200 && status < 300;
      },
      responseType: ResponseType.json,
    );
  }

  /// Creates BaseOptions from DioConfigs
  static BaseOptions fromConfigs(DioConfigs configs) {
    return configs.toBaseOptions().copyWith(
      headers: {
        ..._defaultHeaders,
        ...?configs.headers,
      },
    );
  }

  /// Default headers applied to all requests
  static const Map<String, String> _defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Default timeout constants in milliseconds
  static const _kDefaultReceiveTimeout = 30000;
  static const _kDefaultConnectTimeout = 30000;
  static const _kDefaultSendTimeout = 30000;
}

/// Extension methods for BaseOptions
extension BaseOptionsExtension on BaseOptions {
  /// Adds authorization header with Bearer token
  BaseOptions withBearerToken(String token) {
    if (token.isEmpty) return this;

    final updatedHeaders = Map<String, dynamic>.from(headers);
    updatedHeaders['Authorization'] = 'Bearer $token';

    return copyWith(headers: updatedHeaders);
  }

  /// Sets custom timeout values
  BaseOptions withTimeouts({
    int? receiveTimeoutMs,
    int? connectTimeoutMs,
    int? sendTimeoutMs,
  }) {
    return copyWith(
      receiveTimeout: receiveTimeoutMs != null
          ? Duration(milliseconds: receiveTimeoutMs)
          : receiveTimeout,
      connectTimeout: connectTimeoutMs != null
          ? Duration(milliseconds: connectTimeoutMs)
          : connectTimeout,
      sendTimeout: sendTimeoutMs != null
          ? Duration(milliseconds: sendTimeoutMs)
          : sendTimeout,
    );
  }
}
