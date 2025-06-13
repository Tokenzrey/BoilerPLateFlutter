import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:fpdart/fpdart.dart';

abstract class HomeRepository {
  /// Fetches trending manga comics for male readers with a 180-day window
  ///
  /// Returns Either with TopResponseModel on success or Failure on error
  Future<Either<Failure, TopResponseModel>> fetchTrendingManga();

  /// Fetches comics popular among female readers with a 360-day window
  ///
  /// Returns Either with TopResponseModel on success or Failure on error
  Future<Either<Failure, TopResponseModel>> fetchPopularForFemaleReaders();

  /// Fetches top comics with custom parameters
  ///
  /// Returns Either with TopResponseModel on success or Failure on error
  Future<Either<Failure, TopResponseModel>> fetchTopComics({
    required TopGender gender,
    required TopDay day,
    required TopType type,
    required List<ComicType> comicTypes,
    bool acceptMatureContent,
  });
}
