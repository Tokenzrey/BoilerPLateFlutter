import 'dart:async';
import 'error_response.dart';

/// Status of an API response
enum ResponseStatus {
  /// The request was successful
  success,

  /// The request failed with an error
  error,
}

/// Wrapper for API responses that handles both success and error states
class ResponseWrapper<T> {
  /// The status of the response
  final ResponseStatus status;

  /// The data returned by the API (null if error)
  final T? data;

  /// Error information (null if success)
  final ErrorResponse? error;

  /// Creates a response wrapper
  const ResponseWrapper._({
    required this.status,
    this.data,
    this.error,
  });

  /// Creates a successful response
  factory ResponseWrapper.success(T data) {
    return ResponseWrapper._(
      status: ResponseStatus.success,
      data: data,
    );
  }

  /// Creates an error response
  factory ResponseWrapper.error(ErrorResponse error) {
    return ResponseWrapper._(
      status: ResponseStatus.error,
      error: error,
    );
  }

  /// Creates a generic error response
  factory ResponseWrapper.genericError(String message) {
    return ResponseWrapper._(
      status: ResponseStatus.error,
      error: ErrorResponse.generic(message: message),
    );
  }

  /// Whether this response is successful
  bool get isSuccess => status == ResponseStatus.success;

  /// Whether this response is an error
  bool get isError => status == ResponseStatus.error;

  /// Gets the data or throws an exception if this is an error
  T get dataOrThrow {
    if (isError) {
      throw error!;
    }
    return data as T;
  }

  /// Maps the data to a new type if this is a successful response
  ResponseWrapper<R> mapData<R>(R Function(T data) mapper) {
    if (isError) {
      return ResponseWrapper<R>.error(error!);
    }
    return ResponseWrapper<R>.success(mapper(data as T));
  }

  /// Handles both success and error cases
  R when<R>({
    required R Function(T data) success,
    required R Function(ErrorResponse error) error,
  }) {
    if (isSuccess) {
      return success(data as T);
    } else {
      return error(this.error!);
    }
  }

  /// Executes callback if this is a successful response
  void ifSuccess(void Function(T data) callback) {
    if (isSuccess) {
      callback(data as T);
    }
  }

  /// Executes callback if this is an error response
  void ifError(void Function(ErrorResponse error) callback) {
    if (isError) {
      callback(error!);
    }
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ResponseWrapper.success(data: $data)';
    } else {
      return 'ResponseWrapper.error(error: $error)';
    }
  }

  /// Creates a response wrapper from a Future
  static Future<ResponseWrapper<T>> fromFuture<T>(
    Future<T> future, {
    ErrorResponse Function(dynamic error)? errorMapper,
  }) async {
    try {
      final data = await future;
      return ResponseWrapper<T>.success(data);
    } catch (e) {
      final error =
          errorMapper?.call(e) ?? ErrorResponse.generic(message: e.toString());
      return ResponseWrapper<T>.error(error);
    }
  }
}

/// Extension for working with ResponseWrapper in async contexts
extension FutureResponseWrapperExtension<T> on Future<ResponseWrapper<T>> {
  /// Maps the data in this response wrapper once the future completes
  Future<ResponseWrapper<R>> mapData<R>(R Function(T data) mapper) async {
    final response = await this;
    return response.mapData(mapper);
  }

  /// Executes callbacks based on the response status once the future completes
  Future<void> listen({
    void Function(T data)? onSuccess,
    void Function(ErrorResponse error)? onError,
    void Function()? onComplete,
  }) async {
    try {
      final response = await this;
      if (response.isSuccess && onSuccess != null) {
        onSuccess(response.data as T);
      } else if (response.isError && onError != null) {
        onError(response.error!);
      }
    } finally {
      onComplete?.call();
    }
  }
}
