import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/models/comic_chapters_model.dart';
import 'package:boilerplate/data/local/models/comic_details_model.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

abstract class ComicDetailsRepository {
  /// Fetches comic details by slug
  ///
  /// [slug] The unique identifier for the comic
  /// [tachiyomi] Optional flag for Tachiyomi client requests
  Future<Either<Failure, ComicDetailResponse>> fetchComicDetails({
    required String slug,
    bool? tachiyomi,
    int? t,
    CancelToken? cancelToken,
  });

  /// Fetches chapters of a comic by hidden ID
  ///
  /// [hid] - The comic's unique hidden identifier (required)
  /// [limit] - Number of chapters to return per page (default: 60)
  /// [page] - Page number for pagination (minimum: 0)
  /// [chapOrder] - Chapter ordering (default: 0)
  /// [dateOrder] - Date ordering
  /// [lang] - Language filter (e.g., "gb", "fr", "de")
  /// [chap] - Specific chapter filter
  /// [tachiyomi] - Flag for Tachiyomi client requests
  Future<Either<Failure, ComicChaptersResponse>> fetchChapterDetails({
    required String hid,
    int? limit,
    int? page,
    int? chapOrder,
    int? dateOrder,
    String? lang,
    String? chap,
    bool? tachiyomi,
    CancelToken? cancelToken,
  });
}
