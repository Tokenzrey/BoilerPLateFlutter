import 'dart:async';
import 'package:boilerplate/data/network/dio/models/error_response.dart';
import 'package:dio/dio.dart';

import '../dio_client.dart';
import 'exception/network_error.dart';
import 'models/pagination_meta.dart';
import 'models/response_wrapper.dart';

/// Base class for API service implementations
abstract class BaseApi {
  /// The DioClient instance for making HTTP requests
  final DioClient _client;

  /// Creates a new API service with the specified client
  BaseApi(this._client);

  /// Access to the raw DioClient
  DioClient get client => _client;

  /// Performs a GET request and maps the response to the specified type
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _client.get(
        path,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      if (mapper != null) {
        return mapper(response);
      }

      return response as T;
    } on NetworkError catch (e) {
      throw _processNetworkError(e, path);
    }
  }

  /// Performs a POST request and maps the response to the specified type
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _client.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (mapper != null) {
        return mapper(response);
      }

      return response as T;
    } on NetworkError catch (e) {
      throw _processNetworkError(e, path);
    }
  }

  /// Performs a PUT request and maps the response to the specified type
  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _client.put(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (mapper != null) {
        return mapper(response);
      }

      return response as T;
    } on NetworkError catch (e) {
      throw _processNetworkError(e, path);
    }
  }

  /// Performs a PATCH request and maps the response to the specified type
  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _client.patch(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      if (mapper != null) {
        return mapper(response);
      }

      return response as T;
    } on NetworkError catch (e) {
      throw _processNetworkError(e, path);
    }
  }

  /// Performs a DELETE request and maps the response to the specified type
  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _client.delete(
        path,
        data: data,
        queryParameters: queryParams,
        options: options,
        cancelToken: cancelToken,
      );

      if (mapper != null) {
        return mapper(response);
      }

      return response as T;
    } on NetworkError catch (e) {
      throw _processNetworkError(e, path);
    }
  }

  /// Performs a GET request and wraps the response in a ResponseWrapper
  Future<ResponseWrapper<T>> safeGet<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await get<T>(
        path,
        queryParams: queryParams,
        mapper: mapper,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return ResponseWrapper.success(response);
    } on NetworkError catch (e) {
      return ResponseWrapper.error(
        ErrorResponse(
          code: e.code,
          message: e.message,
          errors: e.responseData is Map ? e.responseData : null,
          statusCode: e.statusCode,
        ),
      );
    } catch (e) {
      return ResponseWrapper.genericError(e.toString());
    }
  }

  /// Performs a POST request and wraps the response in a ResponseWrapper
  Future<ResponseWrapper<T>> safePost<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? mapper,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await post<T>(
        path,
        data: data,
        queryParams: queryParams,
        mapper: mapper,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return ResponseWrapper.success(response);
    } on NetworkError catch (e) {
      return ResponseWrapper.error(
        ErrorResponse(
          code: e.code,
          message: e.message,
          errors: e.responseData is Map ? e.responseData : null,
          statusCode: e.statusCode,
        ),
      );
    } catch (e) {
      return ResponseWrapper.genericError(e.toString());
    }
  }

  /// Gets a paginated list of items
  Future<PaginatedList<T>> getPaginated<T>(
    String path, {
    required T Function(Map<String, dynamic> json) itemMapper,
    Map<String, dynamic>? queryParams,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await get<Map<String, dynamic>>(
      path,
      queryParams: queryParams,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );

    return PaginatedList<T>.fromJson(response, itemMapper);
  }

  /// Additional processing for network errors if needed
  NetworkError _processNetworkError(NetworkError error, String path) {
    // You could add custom handling here, logging, etc.

    // Add path information if it's missing
    if (error.path == null) {
      return NetworkError(
        code: error.code,
        message: error.message,
        originalException: error.originalException,
        responseData: error.responseData,
        statusCode: error.statusCode,
        path: path,
      );
    }

    return error;
  }
}
