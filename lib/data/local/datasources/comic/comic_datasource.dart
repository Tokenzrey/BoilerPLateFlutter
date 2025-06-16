import 'package:boilerplate/data/local/models/comic_followed_model.dart';
import 'package:hive/hive.dart';

class FollowedComicLocalDataSource {
  final Box<FollowedComic> _comicBox;

  FollowedComicLocalDataSource(this._comicBox);

  Future<List<FollowedComic>> getFollowedComicsByUserId(String userId) async {
    return _comicBox.values.where((comic) => comic.userId == userId).toList();
  }

  Future<void> followComic(FollowedComic comic) async {
    final exists = _comicBox.values.any(
            (c) => c.userId == comic.userId && c.hid == comic.hid);
    if (!exists) {
      await _comicBox.add(comic);
    }
  }

  Future<void> unfollowComic(String userId, String hid) async {
    final key = _comicBox.keys.firstWhere(
          (key) {
        final c = _comicBox.get(key);
        return c?.userId == userId && c?.hid == hid;
      },
      orElse: () => null,
    );
    if (key != null) {
      await _comicBox.delete(key);
    }
  }
}