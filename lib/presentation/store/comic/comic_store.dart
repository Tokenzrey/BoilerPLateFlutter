import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:boilerplate/domain/usecase/comic/followed_comic_usecase.dart';
import 'package:mobx/mobx.dart';

part 'comic_store.g.dart';

class FollowedComicStore = FollowedComicStoreBase with _$FollowedComicStore;

abstract class FollowedComicStoreBase with Store {
  final AddFollowedComicUseCase addFollowedComicUseCase;

  FollowedComicStoreBase(this.addFollowedComicUseCase);

  @observable
  ObservableList<FollowedComicEntity> followedComics = ObservableList<FollowedComicEntity>();

  @observable
  bool isLoading = false;

  @observable
  String errorMessage = '';

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
          userId: params.userId,
          slug: params.slug,
          hid: params.hid,
          chap: params.chap,
        ));
      },
    );
    isLoading = false;
  }
}