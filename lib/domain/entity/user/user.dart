import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String> roles;
  final String avatar;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.createdAt,
    this.lastLogin,
    this.roles = const ['user'],
    this.avatar = "0",
  });

  factory User.create({
    required String email,
    required String username,
    required String fullName,
    String avatar = "0",
  }) {
    return User(
      id: const Uuid().v4(),
      email: email.toLowerCase().trim(),
      username: username.trim(),
      fullName: fullName.trim(),
      createdAt: DateTime.now(),
      roles: const ['user'],
      avatar: avatar,
    );
  }

  User copyWith({
    String? email,
    String? username,
    String? fullName,
    DateTime? lastLogin,
    List<String>? roles,
    String? avatar,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      roles: roles ?? this.roles,
      avatar: avatar ?? this.avatar,
    );
  }

  @override
  List<Object?> get props =>
      [id, email, username, fullName, createdAt, lastLogin, roles, avatar];
}
