import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference<Map<String, dynamic>> _users =
      FirebaseFirestore.instance.collection('users');

  /// Sign up with email & password
  static Future<UserCredential> signUp(
      {required String email, required String password}) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  static Future<AppUser?> searchUserByNationalId(String nationalId) async {
    final cleanQuery = nationalId.trim().replaceAll(RegExp(r'\s+'), '');

    if (cleanQuery.isEmpty) return null;

    try {
      final snapshot = await _users
          .where('national_id', isEqualTo: cleanQuery)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return AppUser.fromDocument(doc);
      } else {
        return null;
      }
    } catch (e) {
      print("حدث خطأ أثناء البحث عن المستخدم: $e");
      rethrow;
    }
  }

  /// Save additional user data to Firestore under collection 'users'
  static Future<void> saveUserData(String uid, Map<String, dynamic> data) {
    return _users.doc(uid).set(data);
  }

  /// Sign in with email & password
  static Future<UserCredential> signIn(
      {required String email, required String password}) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Get Firestore user document
  static Future<DocumentSnapshot<Map<String, dynamic>>> getUserDoc(String uid) {
    return _users.doc(uid).get();
  }

  /// Return the currently signed in user or null
  static User? currentUser() => _auth.currentUser;

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
      await Future.delayed(
          const Duration(milliseconds: 500)); // مهلة قصيرة للتأكد من الإنهاء
      print("User signed out successfully.");
    } catch (e) {
      print("Error during sign out: $e");
      rethrow;
    }
  }

  /// Send a password reset email
  static Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  /// Helper to fetch role (returns 'user' if missing)
  static Future<String> getUserRole(String uid) async {
    final doc = await getUserDoc(uid);
    if (!doc.exists) return 'user';
    return doc.data()?['role'] ?? 'user';
  }

  static Future<List<AppUser>> getAllUsersExceptCurrent() async {
    final currentUid = _auth.currentUser?.uid;
    final snapshot = await _users.get();

    final users = snapshot.docs
        .where((doc) => doc.id != currentUid)
        .map((doc) => AppUser.fromDocument(doc))
        .toList();

    print("Fetched ${users.length} users (excluding current user).");
    return users;
  }

  static Future<void> deleteUser(String uid) async {
    try {
      // أولاً: حذف بيانات المستخدم من Firestore
      await _users.doc(uid).delete();

      print(
          "User with UID $uid deleted from Firestore (Auth deletion requires Admin SDK).");
    } catch (e) {
      print("Error deleting user $uid: $e");
      rethrow;
    }
  }
}

/*
Usage example with AppUser model:

import 'models/app_user.dart';

final doc = await AuthService.getUserDoc(uid);
if (doc.exists) {
  final appUser = AppUser.fromDocument(doc);
  print(appUser.name);
}

Or when creating user data:
await AuthService.saveUserData(user.uid, AppUser(
  uid: user.uid,
  name: '...'
  email: '...'
).toMap());

}
*/
