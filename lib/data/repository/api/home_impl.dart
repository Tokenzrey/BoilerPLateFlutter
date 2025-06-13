import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/home_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Repository implementation for home screen API data
///
/// Handles fetching of comics data from the API service and returns
/// standardized responses using the Either type for error handling.
///
/// Last updated: 2025-06-13 18:55:52 UTC
/// Author: Tokenzrey
class HomeRepositoryImpl implements HomeRepository {
  final TopApiService _topApiService;
  final Logger _logger = getIt<Logger>().withTag('[API] Top API');

  HomeRepositoryImpl({required TopApiService topApiService})
      : _topApiService = topApiService;

  @override
  Future<Either<Failure, TopResponseModel>> fetchTrendingManga() async {
    _logger.info('Fetching trending manga', domain: 'Repository');

    try {
      final response = await _topApiService.getTop(
        gender: TopGender.male,
        day: TopDay.d180,
        type: TopType.trending,
        comicTypes: [ComicType.manga],
        acceptMatureContent: false,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched trending manga',
          domain: 'Repository',
          metadata: {
            'rankCount': response.data!.rank.length,
            'newsCount': response.data!.news.length,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch trending manga',
          domain: 'Repository',
          metadata: {'error': response.error?.message},
        );
        return left(
          ApiFailure(
              response.error?.message ?? 'Failed to load trending comics'),
        );
      }
    } catch (e) {
      _logger.error(
        'Exception while fetching trending manga',
        domain: 'Repository',
        exception: e,
      );
      return left(
        UnexpectedFailure(
            'An error occurred fetching trending manga: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, TopResponseModel>>
      fetchPopularForFemaleReaders() async {
    _logger.info('Fetching popular comics for female readers',
        domain: 'Repository');

    try {
      final response = await _topApiService.getTop(
        gender: TopGender.female,
        day: TopDay.d360,
        type: TopType.follow,
        comicTypes: [ComicType.manga, ComicType.manhwa, ComicType.manhua],
        acceptMatureContent: false,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched popular comics for female readers',
          domain: 'Repository',
          metadata: {
            'rankCount': response.data!.rank.length,
            'trendingCount': response.data!.trending.seven.length,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch popular comics for female readers',
          domain: 'Repository',
          metadata: {'error': response.error?.message},
        );
        return left(
          ApiFailure(
              response.error?.message ?? 'Failed to load popular comics'),
        );
      }
    } catch (e) {
      _logger.error(
        'Exception while fetching popular comics for female readers',
        domain: 'Repository',
        exception: e,
      );
      return left(
        UnexpectedFailure(
            'An error occurred fetching popular comics: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, TopResponseModel>> fetchTopComics({
    required TopGender gender,
    required TopDay day,
    required TopType type,
    required List<ComicType> comicTypes,
    bool acceptMatureContent = false,
  }) async {
    _logger.info(
      'Fetching custom top comics',
      domain: 'Repository',
      metadata: {
        'gender': gender.toString(),
        'day': day.toString(),
        'type': type.toString(),
        'comicTypes': comicTypes.map((e) => e.toString()).toList(),
        'acceptMatureContent': acceptMatureContent,
      },
    );

    try {
      final response = await _topApiService.getTop(
        gender: gender,
        day: day,
        type: type,
        comicTypes: comicTypes,
        acceptMatureContent: acceptMatureContent,
      );

      if (response.isSuccess && response.data != null) {
        _logger.info(
          'Successfully fetched custom top comics',
          domain: 'Repository',
          metadata: {
            'rankCount': response.data!.rank.length,
            'newsCount': response.data!.news.length,
          },
        );
        return right(response.data!);
      } else {
        _logger.warn(
          'Failed to fetch custom top comics',
          domain: 'Repository',
          metadata: {'error': response.error?.message},
        );
        return left(
          ApiFailure(response.error?.message ??
              'Failed to load comics with specified parameters'),
        );
      }
    } catch (e) {
      _logger.error(
        'Exception while fetching custom top comics',
        domain: 'Repository',
        exception: e,
        stackTrace: StackTrace.current,
      );
      return left(
        UnexpectedFailure('An error occurred fetching comics: ${e.toString()}'),
      );
    }
  }
}
