import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String errorMessage = "";

  void clearError() {
    if (errorMessage.isNotEmpty) {
      setState(() => errorMessage = "");
    }
  }

  void login() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => errorMessage = "");

    _signInWithEmail();
  }

  Future<void> _signInWithEmail() async {
    try {
      await FirebaseAuth.instance.signOut();
      await Future.delayed(const Duration(milliseconds: 300));

      final cred = await AuthService.signIn(
          email: usernameController.text.trim(),
          password: passwordController.text);

      final uid = cred.user!.uid;
      final doc = await AuthService.getUserDoc(uid);

      if (!doc.exists) {
        Navigator.pushReplacementNamed(context, '/signup');
        return;
      }

      final role = doc.data()?['role'] ?? 'user';
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/lo');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found') {
          errorMessage = 'المستخدم غير موجود. أنشئ حسابًا جديدًا.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'كلمة المرور غير صحيحة.';
        } else {
          errorMessage = e.message ?? 'خطأ أثناء تسجيل الدخول.';
        }
      });
    } catch (e) {
      setState(() => errorMessage = 'حدث خطأ. حاول مرة أخرى.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade100,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.volunteer_activism,
                          size: 70,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (errorMessage.isNotEmpty)
                        Text(
                          errorMessage,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      TextFormField(
                        controller: usernameController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: "البريد الإلكتروني",
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "الإيميل مطلوب" : null,
                        onChanged: (_) => clearError(),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "كلمة المرور",
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "كلمة المرور مطلوبة" : null,
                        onChanged: (_) => clearError(),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: login,
                          child: const Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/reset_password');
                        },
                        child: const Text(
                          "هل نسيت كلمة المرور؟",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                        child: const Text(
                          "إنشاء حساب جديد",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
