import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:boilerplate/domain/repository/comic/comic_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

  class AddFollowedComicParams extends Equatable {
    final String userId;
    final String slug;
    final String hid;
    final String chap;

    const AddFollowedComicParams({
      required this.userId,
      required this.slug,
      required this.hid,
      required this.chap,
    });

    @override
    List<Object?> get props => [userId, slug, hid, chap];
  }

  class AddFollowedComicUseCase extends UseCase<Unit, AddFollowedComicParams> {
    final FollowedComicRepository repo;
    AddFollowedComicUseCase(this.repo);

    @override
    Future<Either<Failure, Unit>> execute(AddFollowedComicParams params) async {
      final res = await repo.followComic(
          FollowedComicEntity(
              userId: params.userId,
              slug: params.slug,
              hid: params.hid,
              chap: params.chap
          )
      );

      return res;
    }
  }

