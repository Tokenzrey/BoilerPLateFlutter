import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage interface for caching responses
abstract class CacheStore {
  /// Saves a response to the cache
  Future<void> set(String key, CacheEntry entry);

  /// Retrieves a cached response
  Future<CacheEntry?> get(String key);

  /// Removes a cached response
  Future<void> delete(String key);

  /// Removes all cached responses
  Future<void> clear();
}

/// Represents a cached response
class CacheEntry {
  /// The cached response
  final Response response;

  /// When this cache entry expires
  final DateTime expiresAt;

  /// When this cache entry was created
  final DateTime createdAt;

  /// Creates a new cache entry
  CacheEntry({
    required this.response,
    required this.expiresAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Checks if this cache entry is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Converts this cache entry to JSON
  Map<String, dynamic> toJson() => {
        'response': {
          'data': response.data,
          'headers': response.headers.map,
          'statusCode': response.statusCode,
          'statusMessage': response.statusMessage,
        },
        'expiresAt': expiresAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Creates a cache entry from JSON
  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    final responseData = json['response'];
    final headers = Headers();

    (responseData['headers'] as Map).forEach((key, value) {
      if (value is List) {
        headers.set(key.toString(), List<String>.from(value));
      } else {
        headers.set(key.toString(), [value.toString()]);
      }
    });

    final response = Response(
      data: responseData['data'],
      headers: headers,
      statusCode: responseData['statusCode'],
      statusMessage: responseData['statusMessage'],
      requestOptions: RequestOptions(path: ''),
    );

    return CacheEntry(
      response: response,
      expiresAt: DateTime.parse(json['expiresAt']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

/// Configuration options for cache behavior
class CacheOptions {
  /// Default cache duration in seconds
  static const defaultCacheDuration = Duration(minutes: 5);

  /// Whether GET requests should be cached by default
  final bool cacheGet;

  /// Default cache duration for all requests
  final Duration defaultDuration;

  /// Primary key for cache options in request extras
  static const String extraCacheOptionsKey = 'cache_options';

  /// Whether to force cached response
  final bool forceCache;

  /// Whether to clear the cache for the given request
  final bool clearCache;

  /// Creates cache options with the specified configuration
  const CacheOptions({
    this.cacheGet = true,
    this.defaultDuration = defaultCacheDuration,
    this.forceCache = false,
    this.clearCache = false,
  });

  /// Creates a copy of these options with some fields replaced
  CacheOptions copyWith({
    bool? cacheGet,
    Duration? defaultDuration,
    bool? forceCache,
    bool? clearCache,
  }) {
    return CacheOptions(
      cacheGet: cacheGet ?? this.cacheGet,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      forceCache: forceCache ?? this.forceCache,
      clearCache: clearCache ?? this.clearCache,
    );
  }

  /// Gets cache options from request options or returns default
  static CacheOptions fromExtra(
    RequestOptions options, {
    CacheOptions defaultOptions = const CacheOptions(),
  }) {
    return options.extra[extraCacheOptionsKey] ?? defaultOptions;
  }

  /// Converts these options to a map for request extras
  Map<String, dynamic> toExtra() => {extraCacheOptionsKey: this};

  /// Merges these cache options into existing options
  Options mergeIn(Options options) {
    final Map<String, dynamic> extras = <String, dynamic>{}
      ..addAll(options.extra ?? {})
      ..addAll(toExtra());

    return options.copyWith(extra: extras);
  }
}

/// Extension for adding cache options to requests
extension CacheOptionsExtension on Options {
  /// Creates a copy of options with cache enabled
  Options withCache({Duration? duration, bool? forceCache}) {
    final existing = extra?[CacheOptions.extraCacheOptionsKey] as CacheOptions?;
    final newOptions = (existing ?? const CacheOptions()).copyWith(
      defaultDuration: duration,
      forceCache: forceCache,
    );

    final Map<String, dynamic> extras = <String, dynamic>{}
      ..addAll(extra ?? {})
      ..addAll(newOptions.toExtra());

    return copyWith(extra: extras);
  }

  /// Creates a copy of options that will clear cache for the request
  Options clearCache() {
    final existing = extra?[CacheOptions.extraCacheOptionsKey] as CacheOptions?;
    final newOptions = (existing ?? const CacheOptions()).copyWith(
      clearCache: true,
    );

    final Map<String, dynamic> extras = <String, dynamic>{}
      ..addAll(extra ?? {})
      ..addAll(newOptions.toExtra());

    return copyWith(extra: extras);
  }
}

/// Interceptor that caches responses for faster subsequent requests
class CacheInterceptor extends Interceptor {
  /// Storage for cached responses
  final CacheStore _store;

  /// Default options for caching
  final CacheOptions _defaultOptions;

  /// Creates a cache interceptor with the specified configuration
  CacheInterceptor(
    this._store, {
    CacheOptions defaultOptions = const CacheOptions(),
  }) : _defaultOptions = defaultOptions;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final cacheOptions = CacheOptions.fromExtra(
      options,
      defaultOptions: _defaultOptions,
    );

    // Skip cache for non-GET requests unless explicitly enabled
    if (options.method != 'GET' && !cacheOptions.cacheGet) {
      return handler.next(options);
    }

    // Clear cache if requested
    if (cacheOptions.clearCache) {
      final cacheKey = _generateCacheKey(options);
      await _store.delete(cacheKey);
      return handler.next(options);
    }

    // Try to get cached response
    final cacheKey = _generateCacheKey(options);
    final cacheEntry = await _store.get(cacheKey);

    // Return cached response if valid or if force cache is enabled
    if (cacheEntry != null &&
        (!cacheEntry.isExpired || cacheOptions.forceCache)) {
      // Add cache information to headers for debugging
      cacheEntry.response.headers.set(
        'x-cached-from',
        ['true'],
      );
      cacheEntry.response.headers.set(
        'x-cached-at',
        [cacheEntry.createdAt.toIso8601String()],
      );
      cacheEntry.response.headers.set(
        'x-cached-until',
        [cacheEntry.expiresAt.toIso8601String()],
      );

      if (cacheEntry.isExpired) {
        cacheEntry.response.headers.set(
          'x-cache-expired',
          ['true'],
        );
      }

      if (kDebugMode) {
        print('[Cache] Serving cached response for: ${options.uri}');
      }

      return handler.resolve(cacheEntry.response);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // Only cache successful GET responses by default
    if (response.requestOptions.method != 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final cacheOptions = CacheOptions.fromExtra(
        response.requestOptions,
        defaultOptions: _defaultOptions,
      );

      if (cacheOptions.cacheGet) {
        final cacheKey = _generateCacheKey(response.requestOptions);
        final expiresAt = DateTime.now().add(cacheOptions.defaultDuration);

        final cacheEntry = CacheEntry(
          response: response,
          expiresAt: expiresAt,
        );

        await _store.set(cacheKey, cacheEntry);

        // Add cache headers to response
        response.headers.set(
          'x-cached-at',
          [cacheEntry.createdAt.toIso8601String()],
        );
        response.headers.set(
          'x-cached-until',
          [expiresAt.toIso8601String()],
        );

        if (kDebugMode) {
          print('[Cache] Stored response for: ${response.requestOptions.uri}');
        }
      }
    }

    return handler.next(response);
  }

  /// Generates a unique cache key for the request
  String _generateCacheKey(RequestOptions request) {
    final buffer = StringBuffer()
      ..write(request.method)
      ..write(request.baseUrl)
      ..write(request.path);

    // Add query parameters if present
    if (request.queryParameters.isNotEmpty) {
      final sortedParams = Map.fromEntries(
          request.queryParameters.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key)));
      buffer.write(jsonEncode(sortedParams));
    }

    // Add headers that might affect response (e.g. Accept-Language)
    final relevantHeaders = <String, dynamic>{};
    // Using a for loop instead of forEach for better style
    for (final header in ['accept-language', 'content-type', 'accept']) {
      if (request.headers.containsKey(header)) {
        relevantHeaders[header] = request.headers[header];
      }
    }

    if (relevantHeaders.isNotEmpty) {
      buffer.write(jsonEncode(relevantHeaders));
    }

    // Generate MD5 hash of the buffer content
    final bytes = utf8.encode(buffer.toString());
    final digest = md5.convert(bytes);
    return digest.toString();
  }
}

/// A persistent cache store implementation using SharedPreferences
class SharedPrefsCacheStore implements CacheStore {
  final SharedPreferences _prefs;

  /// Prefix for cache keys to avoid collision with other preferences
  final String _keyPrefix;

  /// Maximum number of cache entries to store
  final int _maxEntries;

  /// Maximum age of cache entries in milliseconds (default: 7 days)
  final int _maxAgeMs;

  /// Creates a new SharedPreferences-based cache store
  SharedPrefsCacheStore(
    this._prefs, {
    String keyPrefix = 'network_cache_',
    int maxEntries = 100,
    int maxAgeMs = 7 * 24 * 60 * 60 * 1000, // 7 days
  })  : _keyPrefix = keyPrefix,
        _maxEntries = maxEntries,
        _maxAgeMs = maxAgeMs;

  String _getPrefKey(String key) => '$_keyPrefix$key';

  @override
  Future<CacheEntry?> get(String key) async {
    final jsonStr = _prefs.getString(_getPrefKey(key));
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      final entry = CacheEntry.fromJson(json);

      // Auto-clean expired entries when accessed
      final now = DateTime.now();
      final entryAge = now.difference(entry.createdAt).inMilliseconds;
      if (entryAge > _maxAgeMs) {
        await delete(key);
        return null;
      }

      return entry;
    } catch (e) {
      // If parsing fails, remove the invalid entry
      await delete(key);
      return null;
    }
  }

  @override
  Future<void> set(String key, CacheEntry entry) async {
    // Check if we need to clean up old entries
    await _cleanupIfNeeded();

    try {
      // Serialize and store the entry
      final jsonStr = jsonEncode(entry.toJson());
      await _prefs.setString(_getPrefKey(key), jsonStr);
    } catch (e) {
      // If serialization fails, just log and continue
      if (kDebugMode) {
        print('Failed to cache response: $e');
      }
    }
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(_getPrefKey(key));
  }

  @override
  Future<void> clear() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Cleans up older entries if we exceed maximum cache size
  Future<void> _cleanupIfNeeded() async {
    final keys =
        _prefs.getKeys().where((key) => key.startsWith(_keyPrefix)).toList();

    if (keys.length < _maxEntries) return;

    // We need to clean up - get all entries and sort by expiration
    final entries = <String, DateTime>{};

    for (final key in keys) {
      final jsonStr = _prefs.getString(key);
      if (jsonStr != null) {
        try {
          final json = jsonDecode(jsonStr) as Map<String, dynamic>;
          final expiresAt = DateTime.parse(json['expiresAt'] as String);
          entries[key] = expiresAt;
        } catch (e) {
          // Remove invalid entries
          await _prefs.remove(key);
        }
      }
    }

    // Sort by expiration date (oldest first)
    final sortedKeys = entries.keys.toList()
      ..sort((a, b) => entries[a]!.compareTo(entries[b]!));

    // Remove enough entries to get under the limit
    final numberOfEntriesToRemove = keys.length -
        _maxEntries +
        10; // Remove extra to avoid frequent cleanups
    if (numberOfEntriesToRemove > 0) {
      for (int i = 0;
          i < numberOfEntriesToRemove && i < sortedKeys.length;
          i++) {
        await _prefs.remove(sortedKeys[i]);
      }
    }
  }
}
