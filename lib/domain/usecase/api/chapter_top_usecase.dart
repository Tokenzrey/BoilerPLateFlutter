import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/home_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for the LatestChaptersUseCase
class LatestChaptersParams {
  final List<String>? lang;
  final int? page;
  final ChapterGender? gender;
  final ChapterOrderType order;
  final dynamic deviceMemory;
  final bool? tachiyomi;
  final List<ChapterType>? types;
  final bool? acceptEroticContent;

  const LatestChaptersParams({
    this.lang,
    this.page = 1,
    this.gender = ChapterGender.male,
    this.order = ChapterOrderType.hot,
    this.deviceMemory,
    this.tachiyomi = true,
    this.types,
    this.acceptEroticContent = true,
  });

  /// Preset: hot chapters in English
  factory LatestChaptersParams.hotEnglish() => const LatestChaptersParams(
        lang: ['en'],
        page: 1,
        order: ChapterOrderType.hot,
        acceptEroticContent: false,
      );

  /// Preset: latest manga updates
  factory LatestChaptersParams.latestManga() => const LatestChaptersParams(
        order: ChapterOrderType.new_,
        types: [ChapterType.manga],
        page: 1,
        acceptEroticContent: false,
      );

  /// Preset: for female readers
  factory LatestChaptersParams.forFemaleReaders() => const LatestChaptersParams(
        gender: ChapterGender.female,
        order: ChapterOrderType.hot,
        types: [ChapterType.manhwa, ChapterType.manhua],
        page: 1,
        acceptEroticContent: false,
      );

  @override
  String toString() {
    return 'LatestChaptersParams{lang: $lang, page: $page, gender: $gender, '
        'order: $order, types: ${types?.length ?? 0}, '
        'acceptEroticContent: $acceptEroticContent}';
  }
}

/// Use case for accessing latest chapters functionality
class LatestChaptersUseCase
    extends UseCase<List<ChapterResponseModel>, LatestChaptersParams> {
  final HomeRepository _homeRepository;
  final Logger _logger;

  LatestChaptersUseCase(this._homeRepository)
      : _logger = getIt<Logger>().withTag('[API] Latest Chapters');

  @override
  Future<Either<Failure, List<ChapterResponseModel>>> execute(
      LatestChaptersParams params) async {
    _logger.info(
      'Executing latest chapters API request',
      domain: 'UseCase',
      metadata: {
        'page': params.page,
        'order': params.order.toString(),
        'gender': params.gender?.toString(),
        'types': params.types?.map((e) => e.toString()).toList(),
        'languages': params.lang,
        'acceptEroticContent': params.acceptEroticContent,
      },
    );

    final result = await _homeRepository.fetchLatestChapters(
      lang: params.lang,
      page: params.page,
      gender: params.gender,
      order: params.order,
      deviceMemory: params.deviceMemory,
      tachiyomi: params.tachiyomi,
      types: params.types,
      acceptEroticContent: params.acceptEroticContent,
    );

    result.fold(
      (failure) => _logger.error(
        'Latest chapters request failed',
        domain: 'UseCase',
        metadata: {'error': failure.message},
      ),
      (data) => _logger.info(
        'Latest chapters request successful',
        domain: 'UseCase',
        metadata: {'itemCount': data.length},
      ),
    );

    return result;
  }
}
