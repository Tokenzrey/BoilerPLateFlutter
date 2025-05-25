import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:boilerplate/data/local/models/user_firebase_model.dart';

class AuthFirebaseDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthFirebaseDataSource({
    required this.firebaseAuth,
    required this.firestore,
  });

  Future<FirebaseUserModel> register(
      String email, String password, String username, String fullName) async {
    try {
      final usernameDoc = await firestore
          .collection('usernames')
          .doc(username.toLowerCase())
          .get();

      if (usernameDoc.exists) {
        throw Exception('Username already taken');
      }

      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user!.updateDisplayName(fullName);

      final now = DateTime.now();

      final userData = {
        'email': email,
        'username': username,
        'fullName': fullName,
        'createdAt': Timestamp.fromDate(now),
        'roles': ['user'],
      };

      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);

      await firestore.collection('usernames').doc(username.toLowerCase()).set({
        'uid': userCredential.user!.uid,
      });

      await userCredential.user!.reload();
      final updatedUser = firebaseAuth.currentUser!;

      return FirebaseUserModel.fromFirebase(updatedUser, userData);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<FirebaseUserModel> login(String email, String password) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final now = DateTime.now();
      await firestore.collection('users').doc(userCredential.user!.uid).update({
        'lastLogin': Timestamp.fromDate(now),
      });

      final userDoc = await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      final userData = userDoc.data();

      return FirebaseUserModel.fromFirebase(userCredential.user!, userData);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<FirebaseUserModel> updateUserData(
      String fullName, String username, String? photoUrl) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No authenticated user found');
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final currentData = userDoc.data() ?? {};
      final currentUsername = currentData['username'] as String?;

      if (username != currentUsername) {
        final usernameDoc = await firestore
            .collection('usernames')
            .doc(username.toLowerCase())
            .get();

        if (usernameDoc.exists) {
          throw Exception('Username already taken');
        }

        final batch = firestore.batch();

        if (currentUsername != null) {
          batch.delete(firestore
              .collection('usernames')
              .doc(currentUsername.toLowerCase()));
        }

        batch.set(
          firestore.collection('usernames').doc(username.toLowerCase()),
          {'uid': user.uid},
        );

        await batch.commit();
      }

      await user.updateDisplayName(fullName);

      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'username': username,
        'updatedAt': Timestamp.now(),
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      await user.reload();
      final updatedUser = firebaseAuth.currentUser!;

      final updatedDoc =
          await firestore.collection('users').doc(user.uid).get();

      return FirebaseUserModel.fromFirebase(updatedUser, updatedDoc.data());
    } catch (e) {
      throw Exception('Update user data failed: ${e.toString()}');
    }
  }

  Future<void> updatePassword(
      String currentPassword, String newPassword) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No authenticated user found or user has no email');
      }

      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
    } catch (e) {
      throw Exception('Password update failed: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  Future<FirebaseUserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      return FirebaseUserModel.fromFirebase(user, userDoc.data());
    }
    return null;
  }

  // Future<FirebaseUserModel?> getCompleteCurrentUser() async {
  //   final user = firebaseAuth.currentUser;
  //   if (user != null) {
  //     final userDoc = await firestore.collection('users').doc(user.uid).get();
  //     return FirebaseUserModel.fromFirebase(user, userDoc.data());
  //   }
  //   return null;
  // }
}
