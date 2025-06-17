import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:boilerplate/domain/usecase/comic/followed_comic_usecase.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';

part 'comic_store.g.dart';

class FollowedComicStore = FollowedComicStoreBase with _$FollowedComicStore;

abstract class FollowedComicStoreBase with Store {
  final AddFollowedComicUseCase addFollowedComicUseCase;
  final GetFollowedComicsUseCase getFollowedComicsUseCase;
  final DeleteFollowedComicsUseCase deleteFollowedComicsUseCase;

  FollowedComicStoreBase(this.addFollowedComicUseCase, this.getFollowedComicsUseCase, this.deleteFollowedComicsUseCase);

  @observable
  ObservableList<FollowedComicEntity> followedComics = ObservableList<FollowedComicEntity>();

  @observable
  bool isLoading = false;

  @observable
  String errorMessage = '';

  @observable
  String filterKeyword = '';

  @computed
  List<FollowedComicEntity> get filteredComics {
    if (filterKeyword.isEmpty) return followedComics;
    return followedComics
        .where((comic) => comic.slug.toLowerCase().contains(filterKeyword.toLowerCase()))
        .toList();
  }

  @action
  Future<void> addComic(AddFollowedComicParams params) async {
    isLoading = true;
    errorMessage = '';

    final result = await addFollowedComicUseCase(params);

    result.match(
          (failure) {
        errorMessage = failure.message;
      },
          (_) {
        followedComics.add(FollowedComicEntity(
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
          addedAt: params.addedAt
        ));
      },
    );
    isLoading = false;
  }

  @action
  Future<void> loadComics(String userId) async {
    isLoading = true;
    errorMessage = '';

    final result = await getFollowedComicsUseCase(GetFollowedComicParams(userId: userId));

    result.match(
          (failure) {
        errorMessage = failure.message;
      },
          (comics) {
        followedComics = ObservableList.of(comics);
      },
    );

    isLoading = false;
  }

  @action
  Future<void> removeComic(String comicId) async {
    isLoading = true;
    errorMessage = '';

    final result = await deleteFollowedComicsUseCase(DeleteFollowedComicsParams(comicId: comicId));
    result.match(
          (failure) {
        errorMessage = failure.message;
      },
          (_) {
            followedComics.removeWhere((comic) => comic.id == comicId);
      },
    );

    isLoading = false;
  }
}