import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/dio/base_api.dart';
import 'package:boilerplate/data/network/dio/models/response_wrapper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:dio/dio.dart';

/// Gender parameter for top comics API
enum TopGender {
  male(1),
  female(2);

  final int value;
  const TopGender(this.value);

  @override
  String toString() => name;
}

/// Time range parameter for top comics API
enum TopDay {
  d180(180),
  d270(270),
  d360(360),
  d720(720);

  final int value;
  const TopDay(this.value);

  @override
  String toString() => name;
}

/// Content type parameter for top comics API
enum TopType {
  trending("trending"),
  newFollow("newfollow"),
  follow("follow");

  final String value;
  const TopType(this.value);

  @override
  String toString() => name;
}

/// Comic origin type parameter for top comics API
enum ComicType {
  manga("manga"),
  manhwa("manhwa"),
  manhua("manhua");

  final String value;
  const ComicType(this.value);

  @override
  String toString() => name;
}

/// Service for accessing top comics API endpoints
///
/// Provides methods to fetch comics data with various filtering options
/// including gender, time range, content type, etc.
///
/// Last updated: 2025-06-13 20:19:34 UTC
/// Author: Tokenzrey
class TopApiService extends BaseApi {
  final Logger _logger;

  TopApiService(super.client)
      : _logger = getIt<Logger>().withTag('[API] Top API');

  /// Fetches top comics based on the provided parameters
  ///
  /// Parameters:
  /// - [gender]: Filter by target gender audience (male/female)
  /// - [day]: Time window for data (180/270/360/720 days)
  /// - [type]: Content type (trending/follow/newFollow)
  /// - [comicTypes]: Comic origin types (manga/manhwa/manhua)
  /// - [acceptMatureContent]: Whether to include mature content
  Future<ResponseWrapper<TopResponseModel>> getTop({
    required TopGender gender,
    TopDay day = TopDay.d180,
    TopType type = TopType.trending,
    required List<ComicType> comicTypes,
    bool acceptMatureContent = false,
    CancelToken? cancelToken,
  }) async {
    _logger.info(
      'Fetching top comics',
      domain: 'getTop',
      metadata: {
        'gender': gender.toString(),
        'day': day.toString(),
        'type': type.toString(),
        'comicTypes': comicTypes.map((e) => e.toString()).toList(),
        'acceptMatureContent': acceptMatureContent,
      },
    );

    final queryParams = <String, dynamic>{
      'gender': gender.value,
      'day': day.value,
      'type': type.value,
      'comic_types': comicTypes.map((e) => e.value).toList(),
      'mature_content': acceptMatureContent ? 1 : 0,
    };

    try {
      final response = await safeGet<TopResponseModel>(
        '/top',
        queryParams: queryParams,
        mapper: (data) {
          try {
            if (data == null) {
              _logger.warn('API returned null data', domain: 'getTop.parse');
              return TopResponseModel.empty();
            }

            // Log raw response structure
            if (data is Map<String, dynamic>) {
              _logger.debug(
                'Raw API response structure',
                domain: 'getTop.parse',
                metadata: {
                  'hasRank': data.containsKey('rank'),
                  'hasTrending': data.containsKey('trending'),
                  'keys': data.keys.toList(),
                  'dataType': data.runtimeType.toString(),
                },
              );

              // Try to use direct JSON conversion first
              try {
                return TopResponseModel.fromJson(data);
              } catch (jsonError) {
                _logger.warn(
                  'Standard JSON parsing failed, using transformation',
                  domain: 'getTop.parse',
                );

                // Transform API response to match our model
                return _transformApiResponse(data, type.value);
              }
            } else {
              _logger.warn(
                'API response is not a Map',
                domain: 'getTop.parse',
                metadata: {'dataType': data.runtimeType.toString()},
              );
              return TopResponseModel.empty();
            }
          } catch (parseError) {
            _logger.error(
              'Failed parsing top comics response',
              domain: 'getTop.parse',
              exception: parseError,
            );
            return TopResponseModel.empty();
          }
        },
        cancelToken: cancelToken,
      );

      if (response.isSuccess) {
        _logger.debug(
          'Successfully fetched top comics',
          domain: 'getTop',
          metadata: {
            'rankCount': response.data?.rank.length ?? 0,
            'trendingCount': response.data?.trending.seven.length ?? 0,
            'newsCount': response.data?.news.length ?? 0,
            'status': response.status.name,
          },
        );
      } else {
        _logger.warn(
          'Failed to fetch top comics',
          domain: 'getTop',
          metadata: {
            'error': response.error?.message.toString() ?? 'Unknown error',
            'statusCode': response.status.name,
          },
        );
      }

      return response;
    } catch (e) {
      _logger.error(
        'Exception while fetching top comics',
        domain: 'getTop',
        exception: e,
        metadata: {'queryParams': queryParams},
      );
      rethrow;
    }
  }

  /// Transform API response to match our model structure
  ///
  /// Used as a fallback when direct JSON parsing fails
  TopResponseModel _transformApiResponse(
      Map<String, dynamic> apiData, String type) {
    _logger.debug(
      'Transforming API response',
      domain: 'transform',
      metadata: {
        'type': type,
        'availablePeriods': apiData.keys.toList(),
      },
    );

    try {
      // The API may return the data in different format based on the type
      // We need to handle all possible structures

      // Set up the response structure
      final Map<String, dynamic> transformedData = {
        'rank': <Map<String, dynamic>>[],
        'recentRank': <Map<String, dynamic>>[],
        'trending': {
          '7': <Map<String, dynamic>>[],
          '30': <Map<String, dynamic>>[],
          '90': <Map<String, dynamic>>[]
        },
        'follows': <Map<String, dynamic>>[],
        'news': <Map<String, dynamic>>[],
        'extendedNews': <Map<String, dynamic>>[],
        'completions': <Map<String, dynamic>>[],
        'topFollowNewComics': {
          '7': <Map<String, dynamic>>[],
          '30': <Map<String, dynamic>>[],
          '90': <Map<String, dynamic>>[]
        },
        'topFollowComics': {
          '7': <Map<String, dynamic>>[],
          '30': <Map<String, dynamic>>[],
          '90': <Map<String, dynamic>>[]
        },
        'comicsByCurrentSeason': {
          'year': '',
          'season': '',
          'data': <Map<String, dynamic>>[]
        }
      };

      // Handle case where the API returns data directly by time periods
      if (apiData.containsKey('7') ||
          apiData.containsKey('30') ||
          apiData.containsKey('90')) {
        // Extract data by time period
        final sevenDayData = _extractDataForPeriod(apiData, '7');
        final thirtyDayData = _extractDataForPeriod(apiData, '30');
        final ninetyDayData = _extractDataForPeriod(apiData, '90');

        // Populate trending data
        transformedData['trending']['7'] = _standardizeItemList(sevenDayData);
        transformedData['trending']['30'] = _standardizeItemList(thirtyDayData);
        transformedData['trending']['90'] = _standardizeItemList(ninetyDayData);

        // Use appropriate time period for rank based on type
        if (type == 'trending') {
          transformedData['rank'] = _standardizeItemList(ninetyDayData);
        } else if (type == 'follow') {
          transformedData['rank'] =
              _standardizeItemList(_extractDataForPeriod(apiData, '360'));
        } else if (type == 'newfollow') {
          transformedData['rank'] = _standardizeItemList(thirtyDayData);
        }
      }
      // Handle case where the API returns data in the structure matching our model
      else {
        // Copy the available data from API response to our transformed structure
        for (final key in apiData.keys) {
          if (transformedData.containsKey(key)) {
            transformedData[key] = apiData[key];
          }
        }
      }

      // Convert the transformed data to our model
      return TopResponseModel.fromJson(transformedData);
    } catch (e) {
      _logger.error(
        'Failed to transform API response',
        domain: 'transform',
        exception: e,
      );
      return TopResponseModel.empty();
    }
  }

  // Helper methods for data transformation

  /// Extract data for a specific time period
  List<dynamic> _extractDataForPeriod(
      Map<String, dynamic> data, String period) {
    if (!data.containsKey(period)) return [];
    final periodData = data[period];
    if (periodData is List) return periodData;
    return [];
  }

  /// Standardize API item list format to ensure consistent structure
  List<Map<String, dynamic>> _standardizeItemList(List<dynamic> items) {
    return items.map((item) {
      if (item is! Map<String, dynamic>) {
        return <String, dynamic>{};
      }

      // Ensure key consistency for our model
      return {
        'slug': item['slug'] ?? '',
        'title': item['title'] ?? '',
        'demographic': item['demographic'],
        'content_rating': item['content_rating'] ?? 'safe',
        'genres': item['genres'] is List ? item['genres'] : [],
        'is_english_title': item['is_english_title'],
        'md_titles': item['md_titles'] is List ? item['md_titles'] : [],
        'last_chapter': item['last_chapter'],
        'id': item['id'] ?? 0,
        'md_covers': item['md_covers'] is List ? item['md_covers'] : [],
      };
    }).toList();
  }
}
