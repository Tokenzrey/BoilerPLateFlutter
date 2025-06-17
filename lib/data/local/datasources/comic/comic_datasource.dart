import 'package:boilerplate/data/local/models/comic_followed_model.dart';
import 'package:hive/hive.dart';

class FollowedComicLocalDataSource {
  final Box<FollowedComic> _comicBox;

  FollowedComicLocalDataSource(this._comicBox);

    Future<List<FollowedComic>> getFollowedComicsByUserId(String userId) async {
      return _comicBox.values.where((comic) => comic.userId == userId).toList();
    }

  Future<void> followComic(FollowedComic comic) async {
    await _comicBox.put(comic.id, comic);
  }

  Future<void> unfollowComic(String comicId) async {
    await _comicBox.delete(comicId);
  }
}