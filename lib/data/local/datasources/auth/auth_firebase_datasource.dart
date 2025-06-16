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
      String email, String password, String username, String fullName,
      {String avatar = "0"}) async {
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
        'avatar': avatar,
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
      String fullName, String username, String avatar) async {
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

      await firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'username': username,
        'updatedAt': Timestamp.now(),
        'avatar': avatar,
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

  Future<void> deleteAccount(String password) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('No authenticated user found or user has no email');
      }

      // Re-authenticate user before deletion
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Get user data to find username
      final userDoc = await firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      final username = userData?['username'] as String?;

      // Perform batch delete operations
      final batch = firestore.batch();

      // Delete user document
      batch.delete(firestore.collection('users').doc(user.uid));

      // Delete username entry if it exists
      if (username != null) {
        batch.delete(
            firestore.collection('usernames').doc(username.toLowerCase()));
      }

      // Execute batch operations
      await batch.commit();

      // Finally delete the Firebase Auth user
      await user.delete();
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }

  Future<void> deleteAccountById(String uid) async {
    try {
      // This method would be used by admins to delete other user accounts
      // Check if the document exists first
      final userDoc = await firestore.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final userData = userDoc.data();
      final username = userData?['username'] as String?;

      // Perform batch delete operations
      final batch = firestore.batch();

      // Delete user document
      batch.delete(firestore.collection('users').doc(uid));

      // Delete username entry if it exists
      if (username != null) {
        batch.delete(
            firestore.collection('usernames').doc(username.toLowerCase()));
      }

      // Execute batch operations
      await batch.commit();

      // Delete the Firebase Auth user
      // Note: This requires admin SDK and cannot be done directly from client-side
      // You would need a Firebase Cloud Function or a backend server for this
    } catch (e) {
      throw Exception('Account deletion failed: ${e.toString()}');
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
}
