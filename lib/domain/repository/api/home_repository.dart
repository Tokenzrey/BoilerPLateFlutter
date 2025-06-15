import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

abstract class HomeRepository {
  /// Fetches top comics with flexible parameters
  ///
  /// [gender] default: TopGender.male
  /// [acceptMatureContent] default: true
  Future<Either<Failure, TopResponseModel>> fetchTopComics({
    TopGender gender,
    TopDay? day,
    TopType? type,
    List<ComicType>? comicTypes,
    bool acceptMatureContent,
    CancelToken? cancelToken,
  });

  /// Fetches latest chapters for homepage with flexible parameters
  ///
  /// [order] default: ChapterOrderType.hot
  /// [page] default: 1
  Future<Either<Failure, List<ChapterResponseModel>>> fetchLatestChapters({
    List<String>? lang,
    int? page,
    ChapterGender? gender,
    ChapterOrderType order,
    dynamic deviceMemory,
    bool? tachiyomi,
    List<ChapterType>? types,
    bool? acceptEroticContent,
    CancelToken? cancelToken,
  });
}
