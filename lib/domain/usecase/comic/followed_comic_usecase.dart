import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:boilerplate/domain/repository/comic/comic_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class AddFollowedComicParams extends Equatable {
  final String userId;
  final String slug;
  final String hid;
  final String chap;
  final String title;
  final String imageUrl;
  final String rating;
  final String totalContent;
  final String lastRead;
  final String updatedAt;
  final String addedAt;

  const AddFollowedComicParams(
      {required this.userId,
      required this.slug,
      required this.hid,
      required this.chap,
      required this.title,
      required this.imageUrl,
      required this.rating,
      required this.totalContent,
      required this.lastRead,
      required this.updatedAt,
      required this.addedAt});

  @override
  List<Object?> get props => [
        userId,
        slug,
        hid,
        chap,
        rating,
        totalContent,
        lastRead,
        updatedAt,
        addedAt
      ];
}

class AddFollowedComicUseCase extends UseCase<Unit, AddFollowedComicParams> {
  final FollowedComicRepository repo;
  AddFollowedComicUseCase(this.repo);

  @override
  Future<Either<Failure, Unit>> execute(AddFollowedComicParams params) async {
    final res = await repo.followComic(FollowedComicEntity(
        id: Uuid().v4(),
        userId: params.userId,
        slug: params.slug,
        hid: params.hid,
        chap: params.chap,
        title: params.title,
        imageUrl: params.imageUrl,
        rating: params.rating,
        totalContent: params.totalContent,
        lastRead: params.lastRead,
        updatedAt: params.updatedAt,
        addedAt: params.addedAt));

    return res;
  }
}

class GetFollowedComicParams extends Equatable {
  final String userId;

  const GetFollowedComicParams({
    required this.userId,
  });

  @override
  List<Object?> get props => [userId];
}

class GetFollowedComicsUseCase
    extends UseCase<List<FollowedComicEntity>, GetFollowedComicParams> {
  final FollowedComicRepository repo;
  GetFollowedComicsUseCase(this.repo);

  @override
  Future<Either<Failure, List<FollowedComicEntity>>> execute(
      GetFollowedComicParams params) async {
    return repo.getFollowedComics(params.userId);
  }
}

class DeleteFollowedComicsParams extends Equatable {
  final String comicId;

  const DeleteFollowedComicsParams({required this.comicId});

  @override
  List<Object?> get props => [comicId];
}

class DeleteFollowedComicsUseCase
    extends UseCase<Unit, DeleteFollowedComicsParams> {
  final FollowedComicRepository repo;
  DeleteFollowedComicsUseCase(this.repo);

  @override
  Future<Either<Failure, Unit>> execute(
      DeleteFollowedComicsParams params) async {
    final res = await repo.unfollowComic(params.comicId);
    return res;
  }
}
