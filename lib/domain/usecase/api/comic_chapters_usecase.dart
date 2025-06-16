import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/comic_chapters_model.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/comic_details_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for the ComicChaptersUseCase
class ComicChaptersParams {
  final String hid;
  final int? limit;
  final int? page;
  final int? chapOrder;
  final int? dateOrder;
  final String? lang;
  final String? chap;
  final bool? tachiyomi;
  final CancelToken? cancelToken;

  const ComicChaptersParams({
    required this.hid,
    this.limit = 60, // Default to 60 as per API spec
    this.page,
    this.chapOrder,
    this.dateOrder,
    this.lang,
    this.chap,
    this.tachiyomi = true,
    this.cancelToken,
  });

  /// Create parameters with just the comic ID
  factory ComicChaptersParams.simple(String hid) => ComicChaptersParams(
        hid: hid,
      );

  /// Create parameters with mature content filtering
  factory ComicChaptersParams.filtered(String hid) => ComicChaptersParams(
        hid: hid,
        tachiyomi: false,
      );

  /// Create parameters for a specific language
  factory ComicChaptersParams.byLanguage(String hid, String language) =>
      ComicChaptersParams(
        hid: hid,
        lang: language,
      );

  /// Create parameters for pagination
  factory ComicChaptersParams.paginated(String hid, int pageNumber,
          {int pageSize = 60}) =>
      ComicChaptersParams(
        hid: hid,
        page: pageNumber,
        limit: pageSize,
      );

  /// Create parameters with chapter ordering
  factory ComicChaptersParams.ordered(String hid, {required int chapOrder}) =>
      ComicChaptersParams(
        hid: hid,
        chapOrder: chapOrder,
      );

  @override
  String toString() {
    return 'ComicChaptersParams{hid: $hid, limit: $limit, page: $page, chapOrder: $chapOrder, '
        'dateOrder: $dateOrder, lang: $lang, chap: $chap, tachiyomi: $tachiyomi}';
  }
}

/// Use case for fetching chapters of a comic
class ComicChaptersUseCase
    extends UseCase<ComicChaptersResponse, ComicChaptersParams> {
  final ComicDetailsRepository _comicDetailsRepository;
  final Logger _logger;

  ComicChaptersUseCase(this._comicDetailsRepository)
      : _logger = getIt<Logger>().withTag('[API] Comic Chapters');

  @override
  Future<Either<Failure, ComicChaptersResponse>> execute(
      ComicChaptersParams params) async {
    _logger.info(
      'Executing comic chapters API request',
      domain: 'UseCase',
      metadata: {
        'hid': params.hid,
        'limit': params.limit,
        'page': params.page,
        'chapOrder': params.chapOrder,
        'dateOrder': params.dateOrder,
        'lang': params.lang,
        'chap': params.chap,
        'tachiyomi': params.tachiyomi,
      },
    );

    final result = await _comicDetailsRepository.fetchChapterDetails(
      hid: params.hid,
      limit: params.limit,
      page: params.page,
      chapOrder: params.chapOrder,
      dateOrder: params.dateOrder,
      lang: params.lang,
      chap: params.chap,
      tachiyomi: params.tachiyomi,
      cancelToken: params.cancelToken,
    );

    result.fold(
      (failure) => _logger.error(
        'Comic chapters request failed',
        domain: 'UseCase',
        metadata: {'error': failure.message, 'hid': params.hid},
      ),
      (data) => _logger.info(
        'Comic chapters request successful',
        domain: 'UseCase',
        metadata: {
          'hid': params.hid,
          'chaptersCount': data.chapters?.length ?? 0,
          'total': data.total,
        },
      ),
    );

    return result;
  }
}
