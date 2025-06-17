import 'package:equatable/equatable.dart';

class FollowedComicEntity extends Equatable {
  final String? id;
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

  const FollowedComicEntity({
    this.id,
    required this.userId,
    required this.slug,
    required this.hid,
    required this.chap,
    required this.title,
    required this.imageUrl,
    required this.rating,
    required this.totalContent,
    required this.lastRead,
    required this.updatedAt,
    required this.addedAt
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    slug,
    hid,
    chap,
    title,
    imageUrl,
    rating,
    totalContent,
    lastRead,
    updatedAt,
    addedAt
  ];
}
