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

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.createdAt,
    this.lastLogin,
    this.roles = const ['user'],
  });

  factory User.create({
    required String email,
    required String username,
    required String fullName,
  }) {
    return User(
      id: const Uuid().v4(),
      email: email.toLowerCase().trim(),
      username: username.trim(),
      fullName: fullName.trim(),
      createdAt: DateTime.now(),
      roles: const ['user'],
    );
  }

  User copyWith({
    String? email,
    String? username,
    String? fullName,
    DateTime? lastLogin,
    List<String>? roles,
  }) {
    return User(
      id: id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      roles: roles ?? this.roles,
    );
  }
  
  @override
  List<Object?> get props =>
      [id, email, username, fullName, createdAt, lastLogin, roles];
}
