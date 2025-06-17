import 'package:equatable/equatable.dart';

class HistoryEntity extends Equatable {
  final String userId;
  final String slug;
  final String hid;
  final String chap;
  final DateTime createdAt;

  const HistoryEntity({
    required this.userId,
    required this.slug,
    required this.hid,
    required this.chap,
    required this.createdAt,
  });

  factory HistoryEntity.create({
    String userId = 'guest',
    required String slug,
    required String hid,
    required String chap,
  }) {
    return HistoryEntity(
      userId: userId,
      slug: slug,
      hid: hid,
      chap: chap,
      createdAt: DateTime.now(),
    );
  }

  HistoryEntity copyWith({
    String? userId,
    String? slug,
    String? hid,
    String? chap,
    DateTime? createdAt,
  }) {
    return HistoryEntity(
      userId: userId ?? this.userId,
      slug: slug ?? this.slug,
      hid: hid ?? this.hid,
      chap: chap ?? this.chap,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [userId, slug, hid, chap, createdAt];

  factory HistoryEntity.fromJson(Map<String, dynamic> json) {
    return HistoryEntity(
      userId: json['userId'] as String? ?? 'guest',
      slug: json['slug'] as String? ?? '',
      hid: json['hid'] as String? ?? '',
      chap:json['chap'] as String? ?? '',
      createdAt: json['createdAt'] as DateTime? ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'slug': slug,
      'hid': hid,
      'chap': chap,
      'createdAt': createdAt,
    };
  }
}
