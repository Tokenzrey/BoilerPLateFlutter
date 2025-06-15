import 'package:dio/dio.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/dio/base_api.dart';
import 'package:boilerplate/data/network/dio/models/response_wrapper.dart';

// Enum: Flexible for API param
enum TopGender { male, female }

enum TopDay { d180, d270, d360, d720 }

enum TopType { trending, newFollow, follow }

enum ComicType { manga, manhwa, manhua }

extension TopGenderX on TopGender {
  int get value => index + 1;
}

extension TopDayX on TopDay {
  int get value => [180, 270, 360, 720][index];
}

extension TopTypeX on TopType {
  String get value => ['trending', 'newfollow', 'follow'][index];
}

extension ComicTypeX on ComicType {
  String get value => ['manga', 'manhwa', 'manhua'][index];
}

class TopApiService extends BaseApi {
  TopApiService(super.client);

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

  Future<ResponseWrapper<TopResponseModel>> getTop({
    TopGender? gender,
    TopDay? day,
    TopType? type,
    List<ComicType>? comicTypes,
    bool? acceptMatureContent,
    CancelToken? cancelToken,
  }) {
    final q = <String, dynamic>{};
    if (gender != null) q['gender'] = gender.value;
    if (day != null) q['day'] = day.value;
    if (type != null) q['type'] = type.value;
    if (acceptMatureContent != null) {
      q['accept_mature_content'] = acceptMatureContent ? 'true' : 'false';
    }

    String comicTypesQuery = '';
    if (comicTypes != null && comicTypes.isNotEmpty) {
      comicTypesQuery = comicTypes
          .map((e) => '&comic_types=${Uri.encodeQueryComponent(e.value)}')
          .join('');
    }

    final queryString = buildQuery(q) + comicTypesQuery;
    final url =
        '/top?${queryString.isNotEmpty ? queryString.substring(1) : ''}';

    return safeGet<TopResponseModel>(
      url,
      mapper: (data) {
        if (data == null) return TopResponseModel.empty();
        if (data is Map<String, dynamic>) {
          try {
            return TopResponseModel.fromJson(data);
          } catch (_) {
            return _fallbackTransform(data, type?.value);
          }
        }
        return TopResponseModel.empty();
      },
      cancelToken: cancelToken,
    );
  }

  TopResponseModel _fallbackTransform(Map<String, dynamic> data, String? type) {
    final Map<String, dynamic> base = {
      'rank': [],
      'recentRank': [],
      'trending': {'7': [], '30': [], '90': []},
      'follows': [],
      'news': [],
      'extendedNews': [],
      'completions': [],
      'topFollowNewComics': {'7': [], '30': [], '90': []},
      'topFollowComics': {'7': [], '30': [], '90': []},
      'comicsByCurrentSeason': {'year': '', 'season': '', 'data': []},
    };

    if (data.containsKey('7') ||
        data.containsKey('30') ||
        data.containsKey('90')) {
      final s7 = _toList(data['7']);
      final s30 = _toList(data['30']);
      final s90 = _toList(data['90']);
      base['trending']['7'] = s7;
      base['trending']['30'] = s30;
      base['trending']['90'] = s90;
      if (type == 'trending') {
        base['rank'] = s90;
      } else if (type == 'follow') {
        base['rank'] = _toList(data['360']);
      } else if (type == 'newfollow') {
        base['rank'] = s30;
      }
    } else {
      data.forEach((k, v) {
        if (base.containsKey(k)) base[k] = v;
      });
    }
    return TopResponseModel.fromJson(base);
  }

  List<Map<String, dynamic>> _toList(dynamic v) {
    if (v is! List) return [];
    return v
        .map<Map<String, dynamic>>((e) => (e is Map<String, dynamic>)
            ? {
                'slug': e['slug'] ?? '',
                'title': e['title'] ?? '',
                'demographic': e['demographic'],
                'content_rating': e['content_rating'] ?? 'safe',
                'genres': e['genres'] is List ? e['genres'] : [],
                'is_english_title': e['is_english_title'],
                'md_titles': e['md_titles'] is List ? e['md_titles'] : [],
                'last_chapter': e['last_chapter'],
                'id': e['id'] ?? 0,
                'md_covers': e['md_covers'] is List ? e['md_covers'] : [],
              }
            : {})
        .toList();
  }
}
