import 'package:boilerplate/data/local/models/comic_details_model.dart';
import 'package:dio/dio.dart';
import 'package:boilerplate/data/network/dio/base_api.dart';
import 'package:boilerplate/data/network/dio/models/response_wrapper.dart';

class ComicDetailApiService extends BaseApi {
  ComicDetailApiService(super.client);

  /// Get information about a comic by its slug
  ///
  /// [slug] - The comic's unique slug identifier
  /// [tachiyomi] - Flag for Tachiyomi client requests
  Future<ResponseWrapper<ComicDetailResponse>> getComicDetail({
    required String slug,
    bool? tachiyomi,
    int? t,
    CancelToken? cancelToken,
  }) {
    final queryParams = <String, dynamic>{};

    if (tachiyomi != null) {
      queryParams['tachiyomi'] = tachiyomi;
    }

    if (t != null) {
      queryParams['t'] = t;
    }

    String url = '/comic/$slug/';
    if (queryParams.isNotEmpty) {
      final queryString = Uri(
          queryParameters: queryParams
              .map((key, value) => MapEntry(key, value.toString()))).query;
      url = '$url?$queryString';
    }

    return safeGet<ComicDetailResponse>(
      url,
      mapper: (data) {
        if (data == null) return ComicDetailResponse.empty();
        if (data is Map<String, dynamic>) {
          try {
            return ComicDetailResponse.fromJson(data);
          } catch (e) {
            return _fallbackTransform(data);
          }
        }
        return ComicDetailResponse.empty();
      },
      cancelToken: cancelToken,
    );
  }

  ComicDetailResponse _fallbackTransform(Map<String, dynamic> data) {
    // Basic fallback in case of parsing issues
    try {
      final comic = data['comic'] as Map<String, dynamic>?;
      final firstChap = data['firstChap'] as Map<String, dynamic>?;

      return ComicDetailResponse(
        comic: comic != null ? ComicModel.fromJson(comic) : ComicModel.empty(),
        firstChap: firstChap != null
            ? FirstChapModel.fromJson(firstChap)
            : FirstChapModel.empty(),
        artists: [],
        authors: [],
        langList: [],
        recommendable: data['recommendable'] as bool? ?? false,
        matureContent: data['matureContent'] as bool? ?? false,
        checkVol2Chap1: data['checkVol2Chap1'] as bool? ?? false,
      );
    } catch (_) {
      return ComicDetailResponse.empty();
    }
  }
}
