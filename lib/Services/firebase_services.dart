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

  static Future<void> handleIndexError(FirebaseException e) async {
    if (e.code == 'failed-precondition' && e.message!.contains('index')) {
      // استخراج رابط الفهرس من رسالة الخطأ
      final regex = RegExp(r'https://console\.firebase\.google\.com[^\s]+');
      final match = regex.firstMatch(e.message!);

      if (match != null) {
        final indexUrl = match.group(0);
        print('❗ الفهرس مطلوب، الرابط: $indexUrl');
        // يمكنك إظهار dialog للمستخدم أو فتح الرابط تلقائياً
      }
    }
  }
}
