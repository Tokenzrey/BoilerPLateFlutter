import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Function type to evaluate whether a request should be retried
typedef RetryEvaluator = FutureOr<bool> Function(DioException error);

/// Interceptor that retries failed requests with customizable logic
class RetryInterceptor extends Interceptor {
  /// The Dio instance to use for retries
  final Dio dio;

  /// Configuration options for retry behavior
  final RetryOptions options;

  /// Whether to log retry attempts
  final bool shouldLog;

  /// Creates a new retry interceptor
  RetryInterceptor({
    required this.dio,
    RetryOptions? options,
    this.shouldLog = true,
  }) : options = options ?? const RetryOptions();

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Extract retry options from request options or use defaults
    var extra = RetryOptions.fromExtra(err.requestOptions, options);

    final shouldRetry = extra.retries > 0 && await options.retryEvaluator(err);
    if (!shouldRetry) {
      return super.onError(err, handler);
    }

    // Calculate exponential backoff delay if enabled
    final retryAttempt = options.retries - extra.retries + 1;
    final backoffInterval = extra.retryInterval.inMilliseconds *
        (extra.useExponentialBackoff ? (1 << (retryAttempt - 1)) : 1);

    if (backoffInterval > 0) {
      await Future.delayed(Duration(milliseconds: backoffInterval));
    }

    // Update options to decrease retry count before new try
    extra = extra.copyWith(retries: extra.retries - 1);
    err.requestOptions.extra = {
      ...err.requestOptions.extra,
      ...extra.toExtra(),
    };

    if (shouldLog) {
      if (kDebugMode) {
        print('[RetryInterceptor] ${err.requestOptions.uri} - '
            'Retrying request (remaining tries: ${extra.retries}, '
            'backoff: ${backoffInterval}ms, error: ${err.message})');
      }
    }

    // Retry with the updated options
    try {
      final response = await dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.reject(e);
    }
  }
}

/// Configuration options for retry behavior
class RetryOptions {
  /// The number of retry attempts in case of an error
  final int retries;

  /// The base interval before a retry
  final Duration retryInterval;

  /// Whether to use exponential backoff for retries
  final bool useExponentialBackoff;

  /// Evaluating if a retry is necessary regarding the error
  RetryEvaluator get retryEvaluator => _retryEvaluator ?? defaultRetryEvaluator;

  final RetryEvaluator? _retryEvaluator;

  /// Creates retry options with the specified configuration
  const RetryOptions({
    this.retries = 3,
    RetryEvaluator? retryEvaluator,
    this.retryInterval = const Duration(seconds: 1),
    this.useExponentialBackoff = true,
  }) : _retryEvaluator = retryEvaluator;

  /// Creates a no-retry configuration
  factory RetryOptions.noRetry() {
    return const RetryOptions(retries: 0);
  }

  /// Key for storing retry options in request extras
  static const extraKey = 'retry_options';

  /// Default evaluator that retries on connection errors and 5xx status codes
  static FutureOr<bool> defaultRetryEvaluator(DioException error) {
    // Don't retry if request was cancelled
    if (error.type == DioExceptionType.cancel) {
      return false;
    }

    // Retry on timeout and connection errors
    final isTimeout = error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;

    // Retry on connection errors
    final isConnectionError = error.type == DioExceptionType.connectionError;

    // Retry on 5xx server errors
    final isServerError = error.response != null &&
        error.response!.statusCode != null &&
        error.response!.statusCode! >= 500 &&
        error.response!.statusCode! < 600;

    return isTimeout || isConnectionError || isServerError;
  }

  /// Extracts retry options from request options or uses defaults
  factory RetryOptions.fromExtra(
    RequestOptions request,
    RetryOptions defaultOptions,
  ) {
    return request.extra[extraKey] ?? defaultOptions;
  }

  /// Creates a copy of these options with some fields replaced
  RetryOptions copyWith({
    int? retries,
    Duration? retryInterval,
    bool? useExponentialBackoff,
  }) =>
      RetryOptions(
        retries: retries ?? this.retries,
        retryInterval: retryInterval ?? this.retryInterval,
        useExponentialBackoff:
            useExponentialBackoff ?? this.useExponentialBackoff,
        retryEvaluator: _retryEvaluator,
      );

  /// Converts these options to a map for request extras
  Map<String, dynamic> toExtra() => {extraKey: this};

  /// Creates request options with these retry options
  Options toOptions() => Options(extra: toExtra());

  /// Merges these retry options into existing options
  Options mergeIn(Options options) {
    return options.copyWith(
      extra: <String, dynamic>{}
        ..addAll(options.extra ?? {})
        ..addAll(toExtra()),
    );
  }

  @override
  String toString() {
    return 'RetryOptions{retries: $retries, retryInterval: $retryInterval, '
        'useExponentialBackoff: $useExponentialBackoff}';
  }
}

/// Extension to convert RequestOptions to Options
extension RequestOptionsExtensions on RequestOptions {
  /// Converts RequestOptions to Options
  Options toOptions() {
    return Options(
      method: method,
      sendTimeout: sendTimeout,
      receiveTimeout: receiveTimeout,
      extra: extra,
      headers: headers,
      responseType: responseType,
      contentType: contentType,
      validateStatus: validateStatus,
      receiveDataWhenStatusError: receiveDataWhenStatusError,
      followRedirects: followRedirects,
      maxRedirects: maxRedirects,
      requestEncoder: requestEncoder,
      responseDecoder: responseDecoder,
      listFormat: listFormat,
    );
  }
}
