import 'package:fpdart/fpdart.dart';
import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/entity/comic/comic.dart';

abstract class FollowedComicRepository {
  Future<Either<Failure, List<FollowedComicEntity>>> getFollowedComics(String userId);
  Future<Either<Failure, Unit>> followComic(FollowedComicEntity comic);
  Future<Either<Failure, Unit>> unfollowComic(FollowedComicEntity comic);
}