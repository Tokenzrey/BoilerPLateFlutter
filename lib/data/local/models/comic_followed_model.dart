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
    @HiveField(4) required String title,
    @HiveField(5) required String imageUrl,
    @HiveField(6) required String rating,
    @HiveField(7) required String totalContent,
    @HiveField(8) required String lastRead,
    @HiveField(9) required String updatedAt,
    @HiveField(10) required String addedAt,
  }) = _FollowedComic;

  factory FollowedComic.create({
    required String userId,
    required String slug,
    required String hid,
    required String chap,
    required String title,
    required String imageUrl,
    required String rating,
    required String totalContent,
    required String lastRead,
    required String updatedAt,
    required String addedAt
  }) {
    return FollowedComic(
      userId: userId,
      slug: slug,
      hid: hid,
      chap: chap,
      title: title,
      imageUrl: imageUrl,
      rating: rating,
      totalContent: totalContent,
      lastRead: lastRead,
      updatedAt: updatedAt,
      addedAt: addedAt
    );
  }

  factory FollowedComic.fromJson(Map<String, Object?> json) =>
      _$FollowedComicFromJson(json);

  factory FollowedComic.fromEntity(FollowedComicEntity entity) =>
      FollowedComic(
        userId: entity.userId,
        slug: entity.slug,
        hid: entity.hid,
        chap: entity.chap,
        title: entity.title,
        imageUrl: entity.imageUrl,
        rating: entity.rating,
        totalContent: entity.totalContent,
        lastRead: entity.lastRead,
        updatedAt: entity.updatedAt,
        addedAt: entity.addedAt
      );
}

extension FollowedComicMapper on FollowedComic {
  FollowedComicEntity toEntity() => FollowedComicEntity(
    userId: userId,
    slug: slug,
    hid: hid,
    chap: chap,
    title: title,
    imageUrl: imageUrl,
    rating: rating,
    totalContent: totalContent,
    lastRead: lastRead,
    updatedAt: updatedAt,
    addedAt: addedAt
  );
}