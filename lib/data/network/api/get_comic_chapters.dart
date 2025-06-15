import 'package:boilerplate/data/local/models/comic_chapters_model.dart';
import 'package:dio/dio.dart';
import 'package:boilerplate/data/network/dio/base_api.dart';
import 'package:boilerplate/data/network/dio/models/response_wrapper.dart';

class ChapterDetailApiService extends BaseApi {
  ChapterDetailApiService(super.client);

  /// Get chapters of a comic by its hidden ID (hid)
  ///
  /// [hid] - The comic's unique hidden identifier (required)
  /// [limit] - Number of chapters to return per page (default: 60)
  /// [page] - Page number for pagination (minimum: 0)
  /// [chapOrder] - Chapter ordering (default: 0)
  /// [dateOrder] - Date ordering
  /// [lang] - Language filter (e.g., "gb", "fr", "de")
  /// [chap] - Specific chapter filter
  /// [tachiyomi] - Flag for Tachiyomi client requests
  Future<ResponseWrapper<ComicChaptersResponse>> getChapterDetail({
    required String hid,
    int? limit = 60,
    int? page,
    int? chapOrder,
    int? dateOrder,
    String? lang,
    String? chap,
    bool? tachiyomi,
    CancelToken? cancelToken,
  }) {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };

    if (page != null) {
      queryParams['page'] = page;
    }

    if (chapOrder != null) {
      queryParams['chap-order'] = chapOrder;
    }

    if (dateOrder != null) {
      queryParams['date-order'] = dateOrder;
    }

    if (lang != null) {
      queryParams['lang'] = lang;
    }

    if (chap != null) {
      queryParams['chap'] = chap;
    }

    if (tachiyomi != null) {
      queryParams['tachiyomi'] = tachiyomi;
    }

    String url = '/comic/$hid/chapters';
    if (queryParams.isNotEmpty) {
      final queryString = Uri(
          queryParameters: queryParams
              .map((key, value) => MapEntry(key, value.toString()))).query;
      url = '$url?$queryString';
    }

    return safeGet<ComicChaptersResponse>(
      url,
      mapper: (data) {
        if (data == null) return ComicChaptersResponse.empty();
        if (data is Map<String, dynamic>) {
          try {
            return ComicChaptersResponse.fromJson(data);
          } catch (e) {
            return _fallbackTransform(data);
          }
        }
        return ComicChaptersResponse.empty();
      },
      cancelToken: cancelToken,
    );
  }

  ComicChaptersResponse _fallbackTransform(Map<String, dynamic> data) {
    // Basic fallback in case of parsing issues
    try {
      final chapters = data['chapters'] as List<dynamic>?;

      return ComicChaptersResponse(
        chapters: chapters != null
            ? chapters
                .whereType<Map<String, dynamic>>()
                .map((item) => ChapterDetailModel.fromJson(item))
                .toList()
            : [],
        total: data['total'] as int? ?? 0,
        checkVol2Chap1: data['checkVol2Chap1'] as bool? ?? false,
        limit: data['limit'] as int? ?? 0,
      );
    } catch (_) {
      return ComicChaptersResponse.empty();
    }
  }
}
