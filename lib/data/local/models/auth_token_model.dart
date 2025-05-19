import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/entity/auth/auth_token.dart';

part 'auth_token_model.freezed.dart';
part 'auth_token_model.g.dart';

@freezed
class AuthTokenModel with _$AuthTokenModel {
  const AuthTokenModel._();

  const factory AuthTokenModel({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
    required String userId,
  }) = _AuthTokenModel;

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      _$AuthTokenModelFromJson(json);

  factory AuthTokenModel.fromEntity(AuthToken token) => AuthTokenModel(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
        expiresAt: token.expiresAt,
        userId: token.userId,
      );

  AuthToken toEntity() => AuthToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: expiresAt,
        userId: userId,
      );
}
