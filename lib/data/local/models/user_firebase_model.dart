import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class FirebaseUserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final List<String> roles;
  final String avatar;

  const FirebaseUserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.createdAt,
    this.lastLogin,
    this.roles = const ['user'],
    this.avatar = "0",
  });

  factory FirebaseUserModel.create({
    required String email,
    required String username,
    required String fullName,
    String avatar = "0",
  }) {
    return FirebaseUserModel(
      id: const Uuid().v4(),
      email: email.toLowerCase().trim(),
      username: username.trim(),
      fullName: fullName.trim(),
      createdAt: DateTime.now(),
      roles: const ['user'],
      avatar: avatar,
    );
  }

  factory FirebaseUserModel.fromFirebase(
    firebase_auth.User firebaseUser,
    Map<String, dynamic>? firestoreData,
  ) {
    final data = firestoreData ?? {};
    final Timestamp? createdTimestamp = data['createdAt'] as Timestamp?;
    final Timestamp? lastLoginTimestamp = data['lastLogin'] as Timestamp?;

    return FirebaseUserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      username: data['username'] ?? '',
      fullName: data['fullName'] ?? firebaseUser.displayName ?? '',
      createdAt: createdTimestamp?.toDate() ?? DateTime.now(),
      lastLogin: lastLoginTimestamp?.toDate(),
      roles: List<String>.from(data['roles'] ?? ['user']),
      avatar: data['avatar'] ?? "0",
    );
  }

  FirebaseUserModel copyWith({
    String? email,
    String? username,
    String? fullName,
    DateTime? lastLogin,
    List<String>? roles,
    String? avatar,
  }) {
    return FirebaseUserModel(
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

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'fullName': fullName,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'roles': roles,
      'avatar': avatar,
    };
  }

  @override
  List<Object?> get props =>
      [id, email, username, fullName, createdAt, lastLogin, roles, avatar];
}
