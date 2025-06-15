import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/core/logging/logger.dart';
import 'package:boilerplate/data/local/models/comic_details_model.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/repository/api/comic_details_repository.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for the ComicDetailsUseCase
class ComicDetailsParams {
  final String slug;
  final bool? tachiyomi;
  final int? t;
  final CancelToken? cancelToken;

  const ComicDetailsParams({
    required this.slug,
    this.tachiyomi = true,
    this.t,
    this.cancelToken,
  });

  /// Create parameters with just the comic slug
  factory ComicDetailsParams.simple(String slug) => ComicDetailsParams(
        slug: slug,
      );

  /// Create parameters with mature content filtering
  factory ComicDetailsParams.filtered(String slug) => ComicDetailsParams(
        slug: slug,
        tachiyomi: false,
      );

  /// Create parameters with timestamp
  factory ComicDetailsParams.withTimestamp(String slug, int timestamp) =>
      ComicDetailsParams(
        slug: slug,
        t: timestamp,
      );

  @override
  String toString() {
    return 'ComicDetailsParams{slug: $slug, tachiyomi: $tachiyomi, t: $t}';
  }
}

/// Use case for fetching detailed information about a comic
class ComicDetailsUseCase
    extends UseCase<ComicDetailResponse, ComicDetailsParams> {
  final ComicDetailsRepository _comicDetailsRepository;
  final Logger _logger;

  ComicDetailsUseCase(this._comicDetailsRepository)
      : _logger = getIt<Logger>().withTag('[API] Comic Details');

  @override
  Future<Either<Failure, ComicDetailResponse>> execute(
      ComicDetailsParams params) async {
    _logger.info(
      'Executing comic details API request',
      domain: 'UseCase',
      metadata: {
        'slug': params.slug,
        'tachiyomi': params.tachiyomi,
        't': params.t,
      },
    );

    final result = await _comicDetailsRepository.fetchComicDetails(
      slug: params.slug,
      tachiyomi: params.tachiyomi,
      t: params.t,
      cancelToken: params.cancelToken,
    );

    result.fold(
      (failure) => _logger.error(
        'Comic details request failed',
        domain: 'UseCase',
        metadata: {'error': failure.message, 'slug': params.slug},
      ),
      (data) => _logger.info(
        'Comic details request successful',
        domain: 'UseCase',
        metadata: {
          'slug': params.slug,
          'title': data.comic?.title,
          'hasFirstChap': data.firstChap != null,
        },
      ),
    );

    return result;
  }
}
