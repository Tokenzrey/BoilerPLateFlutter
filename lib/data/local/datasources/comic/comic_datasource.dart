import 'package:boilerplate/data/local/models/comic_followed_model.dart';
import 'package:hive/hive.dart';

class FollowedComicLocalDataSource {
  final Box<FollowedComic> _comicBox;

  FollowedComicLocalDataSource(this._comicBox);

  Future<List<FollowedComic>> getFollowedComicsByUserId(String userId) async {
    return _comicBox.values.where((comic) => comic.userId == userId).toList();
  }

  Future<void> followComic(FollowedComic comic) async {
    final key = '${comic.userId}_${comic.hid}';
    await _comicBox.put(key, comic);
  }

  Future<void> unfollowComic(String userId, String hid) async {
    final key = '${userId}_$hid';
    await _comicBox.delete(key);
  }
}