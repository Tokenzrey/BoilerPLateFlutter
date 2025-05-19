import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

import 'package:flutter/foundation.dart';
import '../../../domain/entity/user/user.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
@HiveType(typeId: 1)
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @HiveField(0) required String id,
    @HiveField(1) required String email,
    @HiveField(2) required String username,
    @HiveField(3) required String fullName,
    @HiveField(4) required String hashedPassword,
    @HiveField(5) required DateTime createdAt,
    @HiveField(6) DateTime? lastLogin,
    @HiveField(7) @Default(['user']) List<String> roles,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromEntity(User user, {String? hashedPassword}) =>
      UserModel(
        id: user.id,
        email: user.email,
        username: user.username,
        fullName: user.fullName,
        hashedPassword: hashedPassword ?? '',
        createdAt: user.createdAt,
        lastLogin: user.lastLogin,
        roles: user.roles,
      );

  User toEntity() => User(
        id: id,
        email: email,
        username: username,
        fullName: fullName,
        createdAt: createdAt,
        lastLogin: lastLogin,
        roles: roles,
      );
}
