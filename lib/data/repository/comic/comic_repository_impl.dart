import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/datasources/comic/comic_datasource.dart';
import 'package:boilerplate/data/local/models/comic_followed_model.dart';
import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:boilerplate/domain/repository/comic/comic_repository.dart';
import 'package:fpdart/fpdart.dart';

class FollowedComicRepositoryImpl implements FollowedComicRepository {
  final FollowedComicLocalDataSource localDataSource;

  FollowedComicRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<FollowedComicEntity>>> getFollowedComics(String userId) async {
    try {
      final comics = await localDataSource.getFollowedComicsByUserId(userId);
      return right(comics.map((e) => e.toEntity()).toList());
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> followComic(FollowedComicEntity comic) async {
    try {
      final model = FollowedComic.fromEntity(comic);
      await localDataSource.followComic(model);
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unfollowComic(FollowedComicEntity comic) async {
    try {
      final model = FollowedComic.fromEntity(comic);
      await localDataSource.unfollowComic(model);
      return right(unit);
    } catch (e) {
      return left(DatabaseFailure(e.toString()));
    }
  }
}
