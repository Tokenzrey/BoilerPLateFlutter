import 'package:boilerplate/core/logging/logger.dart';
import 'package:dio/dio.dart';

import 'dio/configs/dio_configs.dart';
import 'dio/exception/network_error.dart';

/// A wrapper around Dio HTTP client with enhanced error handling and logging
class DioClient {
  /// The wrapped Dio instance
  final Dio _dio;

  /// Configuration used for this client
  final DioConfigs configs;

  /// Logger for API requests
  final Logger _logger;

  /// Creates a client with the provided Dio instance and configs
  DioClient(this._dio, this.configs, Logger logger)
      : _logger = logger.withTag('[API]');

  /// Access to the underlying Dio instance
  Dio get dio => _dio;

  /// Adds an interceptor to the client
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
    _logger.debug('Added interceptor: ${interceptor.runtimeType}');
  }

  /// Adds multiple interceptors to the client
  void addInterceptors(Iterable<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
    _logger.debug('Added ${interceptors.length} interceptors');
  }

  /// Performs a GET request to the specified endpoint
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _logger.info(
      'GET $path',
      metadata: {
        'queryParams': queryParameters,
        'hasOptions': options != null,
      },
    );

    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      _logger.debug(
        'GET $path completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data as T;
    } on DioException catch (e) {
      _logger.error(
        'GET $path failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Performs a POST request to the specified endpoint
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _logger.info(
      'POST $path',
      metadata: {
        'queryParams': queryParameters,
        'hasData': data != null,
        'hasOptions': options != null,
      },
    );

    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _logger.debug(
        'POST $path completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data as T;
    } on DioException catch (e) {
      _logger.error(
        'POST $path failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Performs a PUT request to the specified endpoint
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _logger.info(
      'PUT $path',
      metadata: {
        'queryParams': queryParameters,
        'hasData': data != null,
        'hasOptions': options != null,
      },
    );

    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _logger.debug(
        'PUT $path completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data as T;
    } on DioException catch (e) {
      _logger.error(
        'PUT $path failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Performs a PATCH request to the specified endpoint
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _logger.info(
      'PATCH $path',
      metadata: {
        'queryParams': queryParameters,
        'hasData': data != null,
        'hasOptions': options != null,
      },
    );

    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _logger.debug(
        'PATCH $path completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data as T;
    } on DioException catch (e) {
      _logger.error(
        'PATCH $path failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Performs a DELETE request to the specified endpoint
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _logger.info(
      'DELETE $path',
      metadata: {
        'queryParams': queryParameters,
        'hasData': data != null,
        'hasOptions': options != null,
      },
    );

    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );

      _logger.debug(
        'DELETE $path completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data as T;
    } on DioException catch (e) {
      _logger.error(
        'DELETE $path failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Performs a request with the given options
  Future<T> request<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _logger.info(
      'REQUEST ${options?.method ?? 'UNKNOWN'} $path',
      metadata: {
        'queryParams': queryParameters,
        'hasData': data != null,
        'hasOptions': options != null,
      },
    );

    try {
      final response = await _dio.request<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      _logger.debug(
        'REQUEST ${options?.method ?? 'UNKNOWN'} $path completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data as T;
    } on DioException catch (e) {
      _logger.error(
        'REQUEST ${options?.method ?? 'UNKNOWN'} $path failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Downloads a file from the server
  Future<dynamic> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    _logger.info(
      'DOWNLOAD from $urlPath to $savePath',
      metadata: {
        'queryParams': queryParameters,
        'deleteOnError': deleteOnError,
      },
    );

    try {
      final response = await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );

      _logger.debug(
        'DOWNLOAD from $urlPath completed with status: ${response.statusCode}',
        metadata: {'contentLength': response.headers.value('content-length')},
      );

      return response.data;
    } on DioException catch (e) {
      _logger.error(
        'DOWNLOAD from $urlPath failed',
        exception: e,
        stackTrace: e.stackTrace,
        metadata: {'url': e.requestOptions.uri.toString()},
      );
      throw _handleError(e);
    }
  }

  /// Handles Dio errors and converts them to NetworkError objects
  Exception _handleError(DioException exception) {
    // If the error object is already a NetworkError, just return it
    if (exception.error is NetworkError) {
      _logger.debug('Using existing NetworkError', metadata: {
        'message': (exception.error as NetworkError).message,
      });
      return exception.error as NetworkError;
    }

    // Otherwise, create a new NetworkError
    final networkError = NetworkError.fromDioException(exception);

    _logger.debug('Created new NetworkError', metadata: {
      'message': networkError.message,
      'statusCode': networkError.statusCode,
    });

    return networkError;
  }
}
