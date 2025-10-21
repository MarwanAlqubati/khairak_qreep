import 'package:flutter/material.dart';
import 'splash.dart';
import 'signup.dart';
import 'login.dart';
import 'resetpassword.dart';
import 'admin.dart';
import 'home.dart';

void main() {
  runApp(KhairakQareebApp());
}

class KhairakQareebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Khairak Qareeb',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Roboto',
      ),
      // ✅ أول صفحة تظهر هي Splash
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(), // البداية
        '/login': (context) => LoginPage(), // بعدها صفحة تسجيل الدخول
        '/signup': (context) => SignUpPage(), // بعدها صفحة التسجيل
        '/reset_password': (context) => ResetPasswordPage(),
        '/admin': (context) => AdminPage(),
        '/lo': (context) => LoPage(),
      },
    );
  }
}
