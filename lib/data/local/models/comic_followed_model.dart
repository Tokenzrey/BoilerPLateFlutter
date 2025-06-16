import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'comic_followed_model.freezed.dart';
part 'comic_followed_model.g.dart';

@freezed
@HiveType(typeId: 3)
class FollowedComic with _$FollowedComic {
  const factory FollowedComic({
    @HiveField(0) required String userId,
    @HiveField(1) required String slug,
    @HiveField(2) required String hid,
    @HiveField(3) required String chap,
    @HiveField(4) required DateTime createdAt,
  }) = _FollowedComic;

  factory FollowedComic.fromJson(Map<String, Object?> json) =>
      _$FollowedComicFromJson(json);

  factory FollowedComic.fromEntity(FollowedComicEntity entity) =>
      FollowedComic(
        userId: entity.userId,
        slug: entity.slug,
        hid: entity.hid,
        chap: entity.chap,
        createdAt: entity.createdAt,
      );
}

extension FollowedComicMapper on FollowedComic {
  FollowedComicEntity toEntity() => FollowedComicEntity(
    userId: userId,
    slug: slug,
    hid: hid,
    chap: chap,
    createdAt: createdAt,
  );
}