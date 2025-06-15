import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/home_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

class HomeRepositoryImpl implements HomeRepository {
  final TopApiService topApiService;
  final ChapterApiService chapterApiService;
  final Logger _logger = getIt<Logger>().withTag('[API] Top API');

  HomeRepositoryImpl(
      {required this.chapterApiService, required this.topApiService});

  @override
  Future<Either<Failure, TopResponseModel>> fetchTopComics({
    TopGender gender = TopGender.male,
    TopDay? day,
    TopType? type,
    List<ComicType>? comicTypes,
    bool acceptMatureContent = true,
    CancelToken? cancelToken,
  }) async {
    _logger.info(
      'Fetching top comics',
      domain: 'Repository',
      metadata: {
        'gender': gender.toString(),
        'day': day?.toString(),
        'type': type?.toString(),
        'comicTypes': comicTypes?.map((e) => e.toString()).toList(),
        'acceptMatureContent': acceptMatureContent,
      },
    );

    try {
      final response = await topApiService.getTop(
        gender: gender,
        day: day,
        type: type,
        comicTypes: comicTypes,
        acceptMatureContent: acceptMatureContent,
        cancelToken: cancelToken,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched top comics',
          domain: 'Repository',
          metadata: {
            'rankCount': response.data!.rank.length,
            'newsCount': response.data!.news.length,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch top comics',
          domain: 'Repository',
          metadata: {'error': response.error?.message},
        );
        return left(
          ApiFailure(response.error?.message ?? 'Failed to load top comics'),
        );
      }
    } catch (e, st) {
      _logger.error(
        'Exception while fetching top comics',
        domain: 'Repository',
        exception: e,
        stackTrace: st,
      );
      return left(
        UnexpectedFailure('An error occurred fetching top comics: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ChapterResponseModel>>> fetchLatestChapters({
    List<String>? lang,
    int? page = 1,
    ChapterGender? gender,
    ChapterOrderType order = ChapterOrderType.hot,
    dynamic deviceMemory,
    bool? tachiyomi,
    List<ChapterType>? types,
    bool? acceptEroticContent,
    CancelToken? cancelToken,
  }) async {
    _logger.info(
      'Fetching latest chapters',
      domain: 'Repository',
      metadata: {
        'page': page,
        'order': order.toString(),
        'gender': gender?.toString(),
        'types': types?.map((e) => e.toString()).toList(),
        'languages': lang,
        'acceptEroticContent': acceptEroticContent,
      },
    );

    try {
      final response = await chapterApiService.getLatestChapters(
        lang: lang,
        page: page,
        gender: gender,
        order: order,
        deviceMemory: deviceMemory,
        tachiyomi: tachiyomi,
        types: types,
        acceptEroticContent: acceptEroticContent,
        cancelToken: cancelToken,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched latest chapters',
          domain: 'Repository',
          metadata: {
            'chapterCount': response.data!.length,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch latest chapters',
          domain: 'Repository',
          metadata: {'error': response.error?.message},
        );
        return left(
          ApiFailure(
              response.error?.message ?? 'Failed to load latest chapters'),
        );
      }
    } catch (e, st) {
      _logger.error(
        'Exception while fetching latest chapters',
        domain: 'Repository',
        exception: e,
        stackTrace: st,
      );
      return left(
        UnexpectedFailure('An error occurred fetching latest chapters: $e'),
      );
    }
  }
}
