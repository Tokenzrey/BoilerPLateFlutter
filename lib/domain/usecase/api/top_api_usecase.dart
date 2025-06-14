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
  final TopDay? day;
  final TopType? type;
  final List<ComicType>? comicTypes;
  final bool acceptMatureContent;

  const TopApiParams({
    this.gender = TopGender.male,
    this.day,
    this.type,
    this.comicTypes,
    this.acceptMatureContent = true,
  });

  /// Preset: trending manga
  factory TopApiParams.trendingManga() => const TopApiParams(
        gender: TopGender.male,
        day: TopDay.d180,
        type: TopType.trending,
        comicTypes: [ComicType.manga],
        acceptMatureContent: false,
      );

  /// Preset: popular for female readers
  factory TopApiParams.popularForFemaleReaders() => const TopApiParams(
        gender: TopGender.female,
        day: TopDay.d360,
        type: TopType.follow,
        comicTypes: [ComicType.manga, ComicType.manhwa, ComicType.manhua],
        acceptMatureContent: false,
      );

  @override
  String toString() {
    return 'TopApiParams{gender: $gender, day: $day, type: $type, comicTypes: ${comicTypes?.length ?? 0}, acceptMatureContent: $acceptMatureContent}';
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
        'day': params.day?.toString(),
        'type': params.type?.toString(),
        'comicTypes': params.comicTypes?.map((e) => e.toString()).toList(),
        'acceptMature': params.acceptMatureContent,
      },
    );

    final result = await _homeRepository.fetchTopComics(
      gender: params.gender,
      day: params.day,
      type: params.type,
      comicTypes: params.comicTypes,
      acceptMatureContent: params.acceptMatureContent,
    );

    result.fold(
      (failure) => _logger.error(
        'Top comics request failed',
        domain: 'UseCase',
        metadata: {'error': failure.message},
      ),
      (data) => _logger.info(
        'Top comics request successful',
        domain: 'UseCase',
        metadata: {'itemCount': data.rank.length},
      ),
    );

    return result;
  }
}
