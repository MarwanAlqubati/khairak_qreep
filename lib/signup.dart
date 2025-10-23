import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ لإظهار التاريخ بصيغة مرتبة
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'models/app_user.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dateController =
      TextEditingController(); // ✅ جديد بدل اليوم/الشهر/السنة

  final List<String> saudiRegions = [
    "الرياض",
    "مكة المكرمة",
    "المدينة المنورة",
    "القصيم",
    "الشرقية",
    "عسير",
    "تبوك",
    "حائل",
    "الباحة",
    "نجران",
    "جازان",
    "الجوف"
  ];

  String? selectedRegion;
  String errorMessage = "";

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000), // تاريخ افتراضي
      firstDate: DateTime(1900), // أقدم تاريخ ممكن
      lastDate: DateTime.now(), // لا يمكن اختيار تاريخ في المستقبل
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.teal, // لون التقويم
              onPrimary: Colors.white, // لون النص داخل الأزرار
              onSurface: Colors.black, // لون النص العام
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
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
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Icon(Icons.volunteer_activism,
                          size: 50, color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        "إنشاء حساب",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (errorMessage.isNotEmpty)
                      Text(
                        errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                          labelText: "الاسم", prefixIcon: Icon(Icons.person)),
                      validator: (value) =>
                          value!.isEmpty ? "الاسم مطلوب" : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          labelText: "الإيميل", prefixIcon: Icon(Icons.email)),
                      validator: (value) =>
                          value!.isEmpty ? "الإيميل مطلوب" : null,
                    ),

                    // ✅ حقل التاريخ الجديد
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "تاريخ الميلاد",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          value!.isEmpty ? "تاريخ الميلاد مطلوب" : null,
                    ),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: "المنطقة",
                          prefixIcon: Icon(Icons.location_city)),
                      value: selectedRegion,
                      items: saudiRegions.map((region) {
                        return DropdownMenuItem(
                            value: region, child: Text(region));
                      }).toList(),
                      onChanged: (value) {
                        print(value);
                        setState(() => selectedRegion = value);
                      },
                      validator: (value) =>
                          value == null ? "اختر المنطقة" : null,
                    ),
                    TextFormField(
                      controller: addressController,
                      decoration: const InputDecoration(
                          labelText: "العنوان", prefixIcon: Icon(Icons.home)),
                      validator: (value) =>
                          value!.isEmpty ? "العنوان مطلوب" : null,
                    ),
                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                          labelText: "رقم الهوية",
                          prefixIcon: Icon(Icons.credit_card)),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? "رقم الهوية مطلوب" : null,
                    ),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                          labelText: "كلمة المرور",
                          prefixIcon: Icon(Icons.lock)),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? "كلمة المرور مطلوبة" : null,
                    ),
                    const SizedBox(height: 25),
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
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            setState(
                                () => errorMessage = "يجب تعبئة جميع الحقول");
                            return;
                          }

                          setState(() => errorMessage = "");

                          try {
                            final cred = await AuthService.signUp(
                                email: emailController.text.trim(),
                                password: passwordController.text);

                            final appUser = AppUser(
                              uid: cred.user!.uid,
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              dob: dateController.text,
                              region: selectedRegion,
                              address: addressController.text.trim(),
                              nationalId: idController.text.trim(),
                              role: 'user',
                              // createdAt left null — we'll use server timestamp when saving
                            );

                            // convert to map but override createdAt with server timestamp
                            final map = appUser.toMap();
                            map['createdAt'] = FieldValue.serverTimestamp();

                            await AuthService.saveUserData(cred.user!.uid, map);

                            Navigator.pushReplacementNamed(context, '/login');
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              if (e.code == 'email-already-in-use') {
                                errorMessage = 'هذا الإيميل مستخدم بالفعل.';
                              } else if (e.code == 'weak-password') {
                                errorMessage = 'كلمة المرور ضعيفة.';
                              } else {
                                errorMessage =
                                    e.message ?? 'خطأ أثناء التسجيل.';
                              }
                            });
                          } catch (e) {
                            setState(() => errorMessage =
                                'حدث خطأ غير متوقع. حاول مرة أخرى.');
                          }
                        },
                        child: const Text(
                          "إنشاء حساب",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const Text(
                          "هل لديك حساب بالفعل؟",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xff75743e),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: const Text(
                            "تسجيل الدخول",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
