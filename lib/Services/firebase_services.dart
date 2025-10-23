import 'dart:html';

import 'package:firebase_auth/firebase_auth.dart';

class FirebaseServices {
  static Future<void> signIn(String username, String password) async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: username, password: password);
  }

  static Future<void> createAccount(String username, String password) async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: username, password: password);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
