import 'dart:async';
import 'package:bcrypt/bcrypt.dart';
import 'package:hive/hive.dart';

import 'package:boilerplate/domain/usecase/user/login_usecase.dart';
import 'package:boilerplate/domain/usecase/user/register_usecase.dart';
import 'package:boilerplate/data/local/models/user_model.dart';
import 'package:uuid/uuid.dart';

class UserLocalDataSource {
  final Box<UserModel> userBox;

  UserLocalDataSource(this.userBox);

  Future<UserModel> login(LoginParams params) async {
    final email = params.email.toLowerCase().trim();
    final password = params.password;

    final user = await findUserByEmail(email);

    if (user == null) {
      throw Exception('Email not found');
    }

    final passwordMatch = BCrypt.checkpw(password, user.hashedPassword);
    if (!passwordMatch) {
      throw Exception('Invalid password');
    }

    final updatedUser = user.copyWith(
      lastLogin: DateTime.now(),
    );

    await userBox.put(user.id, updatedUser);

    return updatedUser;
  }

  Future<UserModel> register(RegisterParams params) async {
    final email = params.email.toLowerCase().trim();
    final username = params.username.trim();
    final password = params.password;

    final emailExists = await findUserByEmail(email);
    if (emailExists != null) {
      throw Exception('Email already registered');
    }

    final usernameExists = await findUserByUsername(username);
    if (usernameExists != null) {
      throw Exception('Username already taken');
    }

    final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

    final newUser = UserModel(
      id: const Uuid().v4(),
      email: email,
      username: username,
      fullName: params.fullName,
      hashedPassword: hashedPassword,
      createdAt: DateTime.now(),
    );

    await userBox.put(newUser.id, newUser);

    return newUser;
  }

  Future<UserModel?> getUser(String id) async {
    return userBox.get(id);
  }

  Future<List<UserModel>> getAllUsers() async {
    return userBox.values.toList();
  }

  Future<UserModel> updateUserData(UserModel user) async {
    final existingUser = await getUser(user.id);
    if (existingUser == null) {
      throw Exception('User not found');
    }

    final updatedUser = user.copyWith(
      hashedPassword: existingUser.hashedPassword,
    );

    await userBox.put(user.id, updatedUser);
    return updatedUser;
  }

  Future<void> updatePassword(
      String userId, String currentPassword, String newPassword) async {
    final existingUser = userBox.get(userId);
    if (existingUser == null) {
      throw Exception('User not found');
    }

    final passwordMatch =
        BCrypt.checkpw(currentPassword, existingUser.hashedPassword);
    if (!passwordMatch) {
      throw Exception('Current password is incorrect');
    }

    final newHashedPassword = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    final updatedUser = existingUser.copyWith(
      hashedPassword: newHashedPassword,
    );

    return await userBox.put(userId, updatedUser);
  }

  Future<void> deleteUser(String id) async {
    if (!userBox.containsKey(id)) {
      throw Exception('User not found');
    }
    await userBox.delete(id);
  }

  Future<void> clearAll() async {
    await userBox.clear();
  }

  Future<UserModel?> findUserByEmail(String email) async {
    final users = userBox.values
        .where((user) => user.email.toLowerCase() == email.toLowerCase().trim())
        .toList();

    return users.isEmpty ? null : users.first;
  }

  Future<UserModel?> findUserByUsername(String username) async {
    final users = userBox.values
        .where((user) =>
            user.username.toLowerCase() == username.toLowerCase().trim())
        .toList();

    return users.isEmpty ? null : users.first;
  }
}
