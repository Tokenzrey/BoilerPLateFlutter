import 'package:dio/dio.dart';

import 'base_api.dart';
import 'models/pagination_meta.dart';
import 'models/response_wrapper.dart';
import '../dio_client.dart';

/// Example model class - Replace with your own model
class ExampleModel {
  final int id;
  final String title;
  final String description;

  ExampleModel({
    required this.id,
    required this.title,
    required this.description,
  });

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
    };
  }
}

/// Template for creating API services with standard CRUD operations
///
/// Usage:
/// ```
/// class UserApi extends ApiServiceTemplate<User> {
///   UserApi(DioClient client) : super(client, '/users');
///
///   @override
///   User Function(Map<String, dynamic> json) get fromJson => User.fromJson;
/// }
/// ```
abstract class ApiServiceTemplate<T> extends BaseApi {
  /// The base endpoint path for this API service
  final String basePath;

  /// Constructor that receives a DioClient and the base path
  ApiServiceTemplate(super.client, this.basePath);

  /// Factory function to convert JSON to model instance - must be implemented by subclasses
  T Function(Map<String, dynamic> json) get fromJson;

  /// Get all items with optional pagination
  Future<PaginatedList<T>> getAll({
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    return getPaginated<T>(
      basePath,
      itemMapper: fromJson,
      queryParams: queryParams,
      cancelToken: cancelToken,
    );
  }

  /// Get a single item by ID
  Future<T> getById(
    dynamic id, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '$basePath/$id',
      queryParams: queryParams,
      cancelToken: cancelToken,
    );

    return fromJson(response);
  }

  /// Create a new item
  Future<T> create(
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    final response = await post<Map<String, dynamic>>(
      basePath,
      data: data,
      cancelToken: cancelToken,
    );

    return fromJson(response);
  }

  /// Update an existing item
  Future<T> update(
    dynamic id,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    final response = await put<Map<String, dynamic>>(
      '$basePath/$id',
      data: data,
      cancelToken: cancelToken,
    );

    return fromJson(response);
  }

  /// Partially update an existing item
  Future<T> partialUpdate(
    dynamic id,
    Map<String, dynamic> data, {
    CancelToken? cancelToken,
  }) async {
    final response = await patch<Map<String, dynamic>>(
      '$basePath/$id',
      data: data,
      cancelToken: cancelToken,
    );

    return fromJson(response);
  }

  /// Delete an item
  @override
  Future<R> delete<R>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    R Function(dynamic)? mapper,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return super.delete(
      '$basePath/$path',
      data: data,
      queryParams: queryParams,
      mapper: mapper,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Example of a safe API call with ResponseWrapper
  Future<ResponseWrapper<T>> safeGetById(
    dynamic id, {
    Map<String, dynamic>? queryParams,
    CancelToken? cancelToken,
  }) async {
    return safeGet<T>(
      '$basePath/$id',
      queryParams: queryParams,
      cancelToken: cancelToken,
      mapper: (json) => fromJson(json as Map<String, dynamic>),
    );
  }
}

/// Example implementation of the API service template
class ExampleApiService extends ApiServiceTemplate<ExampleModel> {
  /// Creates a new example API service
  ExampleApiService(DioClient client) : super(client, '/examples');

  @override
  ExampleModel Function(Map<String, dynamic> json) get fromJson =>
      ExampleModel.fromJson;

  /// Custom method specific to this API
  Future<List<ExampleModel>> searchByTitle(
    String searchTerm, {
    CancelToken? cancelToken,
  }) async {
    final response = await get<List<dynamic>>(
      '$basePath/search',
      queryParams: {'query': searchTerm},
      cancelToken: cancelToken,
    );

    return response
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
