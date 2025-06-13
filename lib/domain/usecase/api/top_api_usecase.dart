import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/home_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for the TopApiUseCase
class TopApiParams {
  final TopGender gender;
  final TopDay day;
  final TopType type;
  final List<ComicType> comicTypes;
  final bool acceptMatureContent;

  const TopApiParams({
    required this.gender,
    required this.day,
    required this.type,
    required this.comicTypes,
    this.acceptMatureContent = false,
  });

  /// Creates parameters for trending manga query
  factory TopApiParams.trendingManga() => const TopApiParams(
        gender: TopGender.male,
        day: TopDay.d180,
        type: TopType.trending,
        comicTypes: [ComicType.manga],
        acceptMatureContent: false,
      );

  /// Creates parameters for female readers' popular comics query
  factory TopApiParams.popularForFemaleReaders() => const TopApiParams(
        gender: TopGender.female,
        day: TopDay.d360,
        type: TopType.follow,
        comicTypes: [ComicType.manga, ComicType.manhwa, ComicType.manhua],
        acceptMatureContent: false,
      );

  @override
  String toString() {
    return 'TopApiParams{gender: $gender, day: $day, type: $type, comicTypes: $comicTypes.length, acceptMatureContent: $acceptMatureContent}';
  }
}

/// Use case for accessing top comics API functionality
class TopApiUseCase extends UseCase<TopResponseModel, TopApiParams> {
  final HomeRepository _homeRepository;
  final Logger _logger;

  TopApiUseCase(this._homeRepository)
      : _logger = getIt<Logger>().withTag('[API] Top API');

  @override
  Future<Either<Failure, TopResponseModel>> execute(TopApiParams params) async {
    _logger.info(
      'Executing top comics API request',
      domain: 'UseCase',
      metadata: {
        'gender': params.gender.toString(),
        'day': params.day.toString(),
        'type': params.type.toString(),
        'comicTypes': params.comicTypes.map((e) => e.toString()).toList(),
        'acceptMature': params.acceptMatureContent,
      },
    );

    // Check if parameters match the trending manga defaults
    if (_isTrendingMangaParams(params)) {
      _logger.debug('Using trending manga preset', domain: 'UseCase');
      final result = await _homeRepository.fetchTrendingManga();

      result.fold(
        (failure) => _logger.error(
          'Trending manga request failed',
          domain: 'UseCase',
          metadata: {'error': failure.message},
        ),
        (data) => _logger.info(
          'Trending manga request successful',
          domain: 'UseCase',
          metadata: {'itemCount': data.rank.length},
        ),
      );

      return result;
    }
    // Check if parameters match the popular for female readers defaults
    else if (_isPopularForFemaleReadersParams(params)) {
      _logger.debug('Using popular for female readers preset',
          domain: 'UseCase');
      final result = await _homeRepository.fetchPopularForFemaleReaders();

      result.fold(
        (failure) => _logger.error(
          'Popular for female readers request failed',
          domain: 'UseCase',
          metadata: {'error': failure.message},
        ),
        (data) => _logger.info(
          'Popular for female readers request successful',
          domain: 'UseCase',
          metadata: {'itemCount': data.rank.length},
        ),
      );

      return result;
    }
    // For other parameter combinations, use the generic method
    else {
      _logger.debug('Using custom parameters for request', domain: 'UseCase');
      final result = await _homeRepository.fetchTopComics(
        gender: params.gender,
        day: params.day,
        type: params.type,
        comicTypes: params.comicTypes,
        acceptMatureContent: params.acceptMatureContent,
      );

      result.fold(
        (failure) => _logger.error(
          'Custom parameters request failed',
          domain: 'UseCase',
          metadata: {'error': failure.message},
        ),
        (data) => _logger.info(
          'Custom parameters request successful',
          domain: 'UseCase',
          metadata: {'itemCount': data.rank.length},
        ),
      );

      return result;
    }
  }

  /// Convenience method to fetch trending manga
  Future<Either<Failure, TopResponseModel>> getTrendingManga() {
    _logger.info('Getting trending manga', domain: 'UseCase');
    return _homeRepository.fetchTrendingManga().then((result) {
      result.fold(
        (failure) => _logger.error(
          'Trending manga shortcut failed',
          domain: 'UseCase',
          metadata: {'error': failure.message},
        ),
        (data) => _logger.info(
          'Trending manga shortcut successful',
          domain: 'UseCase',
          metadata: {'itemCount': data.rank.length},
        ),
      );
      return result;
    });
  }

  /// Convenience method to fetch comics popular with female readers
  Future<Either<Failure, TopResponseModel>> getPopularForFemaleReaders() {
    _logger.info('Getting popular comics for female readers',
        domain: 'UseCase');
    return _homeRepository.fetchPopularForFemaleReaders().then((result) {
      result.fold(
        (failure) => _logger.error(
          'Popular comics for female readers shortcut failed',
          domain: 'UseCase',
          metadata: {'error': failure.message},
        ),
        (data) => _logger.info(
          'Popular comics for female readers shortcut successful',
          domain: 'UseCase',
          metadata: {'itemCount': data.rank.length},
        ),
      );
      return result;
    });
  }

  // Helper methods for parameter checking
  bool _isTrendingMangaParams(TopApiParams params) {
    final isMatch = params.gender == TopGender.male &&
        params.day == TopDay.d180 &&
        params.type == TopType.trending &&
        params.comicTypes.length == 1 &&
        params.comicTypes.contains(ComicType.manga) &&
        !params.acceptMatureContent;

    _logger.debug(
      'Checking if params match trending manga preset',
      domain: 'UseCase',
      metadata: {'isMatch': isMatch},
    );

    return isMatch;
  }

  bool _isPopularForFemaleReadersParams(TopApiParams params) {
    final isMatch = params.gender == TopGender.female &&
        params.day == TopDay.d360 &&
        params.type == TopType.follow &&
        params.comicTypes.length == 3 &&
        params.comicTypes.contains(ComicType.manga) &&
        params.comicTypes.contains(ComicType.manhwa) &&
        params.comicTypes.contains(ComicType.manhua) &&
        !params.acceptMatureContent;

    _logger.debug(
      'Checking if params match female readers preset',
      domain: 'UseCase',
      metadata: {'isMatch': isMatch},
    );

    return isMatch;
  }
}
