import 'package:dio/dio.dart';

/// Default timeout values in milliseconds
const _kDefaultReceiveTimeout = 30000;
const _kDefaultConnectTimeout = 30000;
const _kDefaultSendTimeout = 30000;

/// Configuration class for Dio HTTP client
class DioConfigs {
  /// Base URL for API requests
  final String baseUrl;

  /// Timeout for receiving responses in milliseconds
  final int receiveTimeout;

  /// Timeout for establishing connections in milliseconds
  final int connectTimeout;

  /// Timeout for sending data in milliseconds
  final int sendTimeout;

  /// Additional headers to include in all requests
  final Map<String, String>? headers;

  /// Creates a new DioConfigs instance with the specified parameters
  const DioConfigs({
    required this.baseUrl,
    this.receiveTimeout = _kDefaultReceiveTimeout,
    this.connectTimeout = _kDefaultConnectTimeout,
    this.sendTimeout = _kDefaultSendTimeout,
    this.headers,
  });

  /// Creates a copy of this configuration with modified parameters
  DioConfigs copyWith({
    String? baseUrl,
    int? receiveTimeout,
    int? connectTimeout,
    int? sendTimeout,
    Map<String, String>? headers,
  }) {
    return DioConfigs(
      baseUrl: baseUrl ?? this.baseUrl,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      headers: headers ?? this.headers,
    );
  }

  /// Creates Dio options from this configuration
  BaseOptions toBaseOptions() {
    return BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      connectTimeout: Duration(milliseconds: connectTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      headers: headers ?? const {},
    );
  }
}
