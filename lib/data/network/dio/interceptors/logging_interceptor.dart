import 'dart:convert';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:dio/dio.dart';

/// Log Level for controlling verbosity of logs
enum Level {
  /// No logs
  none,

  /// Logs request and response lines only
  basic,

  /// Logs request and response lines and their respective headers
  headers,

  /// Logs request and response lines and their respective headers and bodies
  body,
}

/// Interceptor that logs HTTP requests and responses
///
/// Provides detailed formatted logging of API requests and responses
/// using the application's Logger system
///
/// Last updated: 2025-06-13 18:40:30 UTC
/// Author: Tokenzrey
class LoggingInterceptor extends Interceptor {
  /// Log level
  final Level level;

  /// Whether to log in compact format
  final bool compact;

  /// Logger instance
  final Logger logger;

  /// Whether to log request/response bodies
  bool get _shouldLogBody => level == Level.body;

  /// Whether to log headers
  bool get _shouldLogHeaders => _shouldLogBody || level == Level.headers;

  final JsonDecoder _decoder = const JsonDecoder();

  /// Creates a logging interceptor with the specified configuration
  LoggingInterceptor({
    required Logger baseLogger,
    this.level = Level.body,
    this.compact = false,
  }) : logger = baseLogger.withTag('[API]');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (level == Level.none) {
      return handler.next(options);
    }

    final metadata = <String, dynamic>{};

    // Add headers to metadata if needed
    if (_shouldLogHeaders) {
      metadata['headers'] = {};
      options.headers.forEach((key, value) {
        metadata['headers'][key] = _redactSensitiveHeader(key, value);
      });

      // Add body to metadata if present
      if (_shouldLogBody && options.data != null) {
        metadata['body'] = _formatBodyForLogging(options.data);
      }
    }

    logger.debug(
      '🌐 Request: ${options.method} ${options.uri}',
      domain: 'HTTP.Request',
      metadata: metadata,
    );

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (level == Level.none) {
      return handler.next(response);
    }

    final request = response.requestOptions;
    final statusCode = response.statusCode;
    final uri = request.uri;
    final metadata = <String, dynamic>{
      'status_code': statusCode,
      'status_message': response.statusMessage,
    };

    // Add headers to metadata if needed
    if (_shouldLogHeaders) {
      metadata['headers'] = {};
      response.headers.forEach((name, values) {
        metadata['headers'][name] = values.join(', ');
      });

      // Add body to metadata if present
      if (_shouldLogBody && response.data != null) {
        metadata['body'] = _formatBodyForLogging(response.data);
      }
    }

    logger.debug(
      '📥 Response: [$statusCode] ${request.method} $uri',
      domain: 'HTTP.Response',
      metadata: metadata,
    );

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (level == Level.none) {
      return handler.next(err);
    }

    final request = err.requestOptions;
    final uri = request.uri;
    final metadata = <String, dynamic>{
      'error_type': err.type.toString(),
    };

    if (err.response != null) {
      metadata['status_code'] = err.response!.statusCode;

      // Add error response data if available
      if (_shouldLogBody && err.response!.data != null) {
        metadata['response_data'] = _formatBodyForLogging(err.response!.data);
      }
    }

    logger.error(
      '❌ Error: [${err.type}] ${request.method} $uri',
      domain: 'HTTP.Error',
      exception: err,
      stackTrace: err.stackTrace,
      metadata: metadata,
    );

    return handler.next(err);
  }

  /// Formats body content for logging metadata
  dynamic _formatBodyForLogging(dynamic data) {
    if (data == null) return null;

    try {
      if (data is Map || (data is String && _isJsonString(data))) {
        // Return as is for structured logging
        return data is String ? _decoder.convert(data) : data;
      } else if (data is List) {
        return data;
      } else {
        return data.toString();
      }
    } catch (e) {
      return 'Error formatting data: ${data.toString()}';
    }
  }

  /// Checks if a string is valid JSON
  bool _isJsonString(String str) {
    try {
      _decoder.convert(str);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Redacts sensitive information in headers
  String _redactSensitiveHeader(String name, dynamic value) {
    final lowerCaseName = name.toLowerCase();
    if (lowerCaseName.contains('token') ||
        lowerCaseName.contains('auth') ||
        lowerCaseName.contains('key') ||
        lowerCaseName.contains('secret') ||
        lowerCaseName.contains('password')) {
      return '••••••REDACTED••••••';
    }
    return value.toString();
  }
}
