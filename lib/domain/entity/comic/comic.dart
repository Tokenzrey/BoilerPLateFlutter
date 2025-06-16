import 'package:equatable/equatable.dart';

class FollowedComicEntity extends Equatable {
  final String userId;
  final String slug;
  final String hid;
  final String chap;
  final DateTime? createdAt;

  const FollowedComicEntity({
    required this.userId,
    required this.slug,
    required this.hid,
    required this.chap,
    this.createdAt,
  });

  @override
  List<Object?> get props => [userId, slug, hid, chap, createdAt];
}
