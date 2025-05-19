import 'package:equatable/equatable.dart';

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String userId;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    required this.userId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get remainingTimeInSeconds =>
      expiresAt.difference(DateTime.now()).inSeconds;

  bool get needsRefresh => remainingTimeInSeconds < 300;

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt, userId];
}
