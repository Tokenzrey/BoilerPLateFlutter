import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/comic_chapters_model.dart';
import 'package:boilerplate/data/local/models/comic_details_model.dart';
import 'package:boilerplate/data/network/api/get_comic_chapters.dart';
import 'package:boilerplate/data/network/api/get_comic_details.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/comic_details_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class ComicDetailsRepositoryImpl implements ComicDetailsRepository {
  final ComicDetailApiService comicDetailApiService;
  final ChapterDetailApiService chapterDetailApiService;
  final Logger _logger = getIt<Logger>().withTag('[API] Comic Details');

  ComicDetailsRepositoryImpl({
    required this.comicDetailApiService,
    required this.chapterDetailApiService,
  });

  @override
  Future<Either<Failure, ComicDetailResponse>> fetchComicDetails({
    required String slug,
    bool? tachiyomi,
    int? t,
    CancelToken? cancelToken,
  }) async {
    _logger.info(
      'Fetching comic details',
      domain: 'Repository',
      metadata: {
        'slug': slug,
        'tachiyomi': tachiyomi,
        't': t,
      },
    );

    try {
      final response = await comicDetailApiService.getComicDetail(
        slug: slug,
        tachiyomi: tachiyomi,
        t: t,
        cancelToken: cancelToken,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched comic details',
          domain: 'Repository',
          metadata: {
            'title': response.data!.comic?.title,
            'slug': response.data!.comic?.slug,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch comic details',
          domain: 'Repository',
          metadata: {'error': response.error?.message, 'slug': slug},
        );
        return left(
          ApiFailure(response.error?.message ?? 'Failed to load comic details'),
        );
      }
    } catch (e, st) {
      _logger.error(
        'Exception while fetching comic details',
        domain: 'Repository',
        exception: e,
        stackTrace: st,
        metadata: {'slug': slug},
      );
      return left(
        UnexpectedFailure('An error occurred fetching comic details: $e'),
      );
    }
  }

  @override
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
  }) async {
    _logger.info(
      'Fetching comic chapters',
      domain: 'Repository',
      metadata: {
        'hid': hid,
        'limit': limit,
        'page': page,
        'chapOrder': chapOrder,
        'dateOrder': dateOrder,
        'lang': lang,
        'chap': chap,
        'tachiyomi': tachiyomi,
      },
    );

    try {
      final response = await chapterDetailApiService.getChapterDetail(
        hid: hid,
        limit: limit,
        page: page,
        chapOrder: chapOrder,
        dateOrder: dateOrder,
        lang: lang,
        chap: chap,
        tachiyomi: tachiyomi,
        cancelToken: cancelToken,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched comic chapters',
          domain: 'Repository',
          metadata: {
            'chaptersCount': response.data!.chapters?.length ?? 0,
            'total': response.data!.total,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch comic chapters',
          domain: 'Repository',
          metadata: {'error': response.error?.message, 'hid': hid},
        );
        return left(
          ApiFailure(
              response.error?.message ?? 'Failed to load comic chapters'),
        );
      }
    } catch (e, st) {
      _logger.error(
        'Exception while fetching comic chapters',
        domain: 'Repository',
        exception: e,
        stackTrace: st,
        metadata: {'hid': hid},
      );
      return left(
        UnexpectedFailure('An error occurred fetching comic chapters: $e'),
      );
    }
  }
}
