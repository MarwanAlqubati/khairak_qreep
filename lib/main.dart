import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'splash.dart';
import 'signup.dart';
import 'login.dart';
import 'resetpassword.dart';
import 'admin.dart';
import 'home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
