import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service interface for managing authentication tokens
abstract class AuthTokenService {
  /// Gets the current access token
  Future<String?> getAccessToken();

  /// Gets a fresh access token (potentially refreshing if needed)
  Future<String?> refreshAccessToken();

  /// Checks if the current token has expired
  Future<bool> isTokenExpired();

  /// Logs the user out and clears tokens
  Future<void> logout();
}

/// Configuration for authentication behavior
class AuthOptions {
  /// Whether to retry with a fresh token on auth errors
  final bool retryWithRefresh;

  /// Whether to log the user out on auth errors after refresh attempts
  final bool logoutOnAuthError;

  /// The authorization scheme (e.g., "Bearer")
  final String authScheme;

  /// The key for storing auth options in request extras
  static const extraKey = 'auth_options';

  /// Creates auth options with the specified configuration
  const AuthOptions({
    this.retryWithRefresh = true,
    this.logoutOnAuthError = false,
    this.authScheme = 'Bearer',
  });

  /// Gets auth options from request options or returns default
  static AuthOptions fromExtra(
    RequestOptions options, {
    AuthOptions defaultOptions = const AuthOptions(),
  }) {
    return options.extra[extraKey] ?? defaultOptions;
  }

  /// Converts these options to a map for request extras
  Map<String, dynamic> toExtra() => {extraKey: this};
}

/// Interceptor that manages authentication tokens for requests
class AuthInterceptor extends Interceptor {
  /// Service for handling authentication tokens
  final AuthTokenService _authTokenService;

  /// Default auth options
  final AuthOptions _defaultAuthOptions;

  /// Dio instance for retrying requests
  final Dio dio;

  /// Lock to prevent multiple simultaneous token refreshes
  final _lock = Lock();

  /// Creates an auth interceptor with the specified configuration
  AuthInterceptor(
    this._authTokenService,
    this.dio, {
    AuthOptions defaultAuthOptions = const AuthOptions(),
  }) : _defaultAuthOptions = defaultAuthOptions;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip authentication if marked to bypass
    if (options.extra.containsKey('bypassAuth') &&
        options.extra['bypassAuth'] == true) {
      return super.onRequest(options, handler);
    }

    final authOptions = AuthOptions.fromExtra(
      options,
      defaultOptions: _defaultAuthOptions,
    );

    try {
      final String? token = await _authTokenService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = '${authOptions.authScheme} $token';
      }
    } catch (e) {
      // Log error but continue with request
      if (kDebugMode) {
        debugPrint('Error getting access token: $e');
      }
    }

    return super.onRequest(options, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 unauthorized errors for retry
    if (err.response?.statusCode != 401) {
      return super.onError(err, handler);
    }

    final authOptions = AuthOptions.fromExtra(
      err.requestOptions,
      defaultOptions: _defaultAuthOptions,
    );

    // If refresh isn't enabled, just pass through the error
    if (!authOptions.retryWithRefresh) {
      return super.onError(err, handler);
    }

    // Don't retry refresh token requests to avoid infinite loops
    if (_isTokenRefreshRequest(err.requestOptions)) {
      if (authOptions.logoutOnAuthError) {
        await _authTokenService.logout();
      }
      return super.onError(err, handler);
    }

    // Use lock to prevent multiple refresh requests
    return _lock.run(() async {
      try {
        // Get a fresh token
        final newToken = await _authTokenService.refreshAccessToken();

        if (newToken == null || newToken.isEmpty) {
          // If refresh failed and logout is enabled, logout
          if (authOptions.logoutOnAuthError) {
            await _authTokenService.logout();
          }
          return super.onError(err, handler);
        }

        // Update the original request with the new token
        err.requestOptions.headers['Authorization'] =
            '${authOptions.authScheme} $newToken';

        // Retry the original request with the new token
        final options = err.requestOptions;
        final response = await dio.request(
          options.path,
          data: options.data,
          queryParameters: options.queryParameters,
          cancelToken: options.cancelToken,
          options: Options(
            method: options.method,
            headers: options.headers,
            responseType: options.responseType,
            contentType: options.contentType,
            receiveTimeout: options.receiveTimeout,
            sendTimeout: options.sendTimeout,
            extra: options.extra,
          ),
        );

        return handler.resolve(response);
      } catch (e) {
        // If refresh failed and logout is enabled, logout
        if (authOptions.logoutOnAuthError) {
          await _authTokenService.logout();
        }

        // Re-wrap any new error or pass through original error
        if (e is DioException) {
          return handler.reject(e);
        }
        return super.onError(err, handler);
      }
    });
  }

  /// Checks if the request is a token refresh request to prevent loops
  bool _isTokenRefreshRequest(RequestOptions options) {
    // This should be customized based on your API's token refresh endpoint
    return options.path.contains('/refresh') ||
        options.path.contains('/token') ||
        options.extra.containsKey('isRefreshRequest');
  }
}

/// Simple lock for synchronizing async operations
class Lock {
  Completer<void>? _completer;

  /// Runs the provided callback while holding the lock
  Future<T> run<T>(Future<T> Function() callback) async {
    // Wait if the lock is already acquired
    if (_completer != null) {
      await _completer!.future;
      return run(callback);
    }

    // Acquire the lock
    _completer = Completer<void>();

    try {
      // Run the callback
      final result = await callback();
      return result;
    } finally {
      // Release the lock
      _completer!.complete();
      _completer = null;
    }
  }
}

/// Extension for adding auth bypass to Options
extension AuthOptionsExtension on Options {
  /// Creates a copy of options that will bypass authentication
  Options bypassAuth() {
    final Map<String, dynamic> newExtra = Map<String, dynamic>.from(extra ?? {})
      ..['bypassAuth'] = true;
    return copyWith(extra: newExtra);
  }

  /// Creates a copy of options that marks this as a token refresh request
  Options markAsRefreshRequest() {
    final Map<String, dynamic> newExtra = Map<String, dynamic>.from(extra ?? {})
      ..['isRefreshRequest'] = true;
    return copyWith(extra: newExtra);
  }
}
