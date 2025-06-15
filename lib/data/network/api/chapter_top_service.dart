import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:dio/dio.dart';
import 'package:boilerplate/data/network/dio/base_api.dart';
import 'package:boilerplate/data/network/dio/models/response_wrapper.dart';

// Enum definitions for chapter API parameters
enum ChapterOrderType { hot, new_ }

enum ChapterGender { male, female }

enum ChapterType { manga, manhwa, manhua }

// Extensions for converting enums to API parameter values
extension ChapterOrderTypeX on ChapterOrderType {
  String get value => ['hot', 'new'][index];
}

extension ChapterGenderX on ChapterGender {
  int get value => index + 1;
}

extension ChapterTypeX on ChapterType {
  String get value => ['manga', 'manhwa', 'manhua'][index];
}

class ChapterApiService extends BaseApi {
  ChapterApiService(super.client);

  String buildQuery(Map<String, dynamic> params) {
    final buffer = StringBuffer();
    params.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        for (final v in value) {
          buffer.write(
              '&${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent('$v')}');
        }
      } else {
        buffer.write(
            '&${Uri.encodeQueryComponent(key)}=${Uri.encodeQueryComponent('$value')}');
      }
    });
    return buffer.toString();
  }

  /// Get latest chapters for homepage
  ///
  /// This endpoint returns the latest chapters based on various filters
  Future<ResponseWrapper<List<ChapterResponseModel>>> getLatestChapters({
    List<String>? lang,
    int? page = 1,
    ChapterGender? gender,
    ChapterOrderType order = ChapterOrderType.hot,
    dynamic deviceMemory,
    bool? tachiyomi,
    List<ChapterType>? types,
    bool? acceptEroticContent,
    CancelToken? cancelToken,
  }) {
    final queryParams = <String, dynamic>{
      'page': page?.clamp(1, 200),
      'order': order.value,
    };

    if (gender != null) {
      queryParams['gender'] = gender.value;
    }

    if (deviceMemory != null) {
      queryParams['device-memory'] = deviceMemory;
    }

    if (tachiyomi != null) {
      queryParams['tachiyomi'] = tachiyomi;
    }

    if (acceptEroticContent != null) {
      queryParams['accept_erotic_content'] = acceptEroticContent;
    }

    String langQuery = '';
    if (lang != null && lang.isNotEmpty) {
      langQuery =
          lang.map((e) => '&lang=${Uri.encodeQueryComponent(e)}').join('');
    }

    String typeQuery = '';
    if (types != null && types.isNotEmpty) {
      typeQuery = types
          .map((e) => '&type=${Uri.encodeQueryComponent(e.value)}')
          .join('');
    }

    final queryString = buildQuery(queryParams) + langQuery + typeQuery;
    final url =
        '/chapter?${queryString.isNotEmpty ? queryString.substring(1) : ''}';

    // Make the API request
    return safeGet<List<ChapterResponseModel>>(
      url,
      mapper: (data) {
        if (data == null) return [];

        if (data is List) {
          try {
            return data
                .map((item) => item is Map<String, dynamic>
                    ? ChapterResponseModel.fromJson(item)
                    : ChapterResponseModel.empty())
                .toList();
          } catch (e) {
            return _fallbackTransform(data);
          }
        }

        return [];
      },
      cancelToken: cancelToken,
    );
  }

  /// Fallback transformation for handling different response formats
  List<ChapterResponseModel> _fallbackTransform(List<dynamic> data) {
    final result = <ChapterResponseModel>[];

    for (final item in data) {
      if (item is! Map<String, dynamic>) continue;

      try {
        final sanitized = <String, dynamic>{
          'id': item['id'] ?? 0,
          'status': item['status'] ?? '',
          'chap': item['chap'] ?? '',
          'vol': item['vol'],
          'last_at': item['last_at'] ?? '',
          'hid': item['hid'] ?? '',
          'created_at': item['created_at'] ?? '',
          'group_name': item['group_name'] is List ? item['group_name'] : [],
          'updated_at': item['updated_at'] ?? '',
          'up_count': item['up_count'] ?? 0,
          'lang': item['lang'] ?? '',
          'down_count': item['down_count'] ?? 0,
          'external_type': item['external_type'],
          'publish_at': item['publish_at'] ?? '',
          'count': item['count'] ?? 0,
        };

        if (item['md_comics'] is Map<String, dynamic>) {
          sanitized['md_comics'] = item['md_comics'];
        } else {
          sanitized['md_comics'] = {
            'id': 0,
            'title': '',
            'slug': '',
            'content_rating': 'safe',
            'genres': [],
            'md_titles': [],
            'md_covers': [],
          };
        }

        result.add(ChapterResponseModel.fromJson(sanitized));
      } catch (_) {
        result.add(ChapterResponseModel.empty());
      }
    }

    return result;
  }
}
