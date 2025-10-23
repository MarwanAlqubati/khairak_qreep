import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'users_management.dart';
import 'models/app_user.dart';

class AddUserPage extends StatefulWidget {
  @override
  _AddUserPageState createState() => _AddUserPageState();
}

class _AddUserPageState extends State<AddUserPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
  bool _isLoading = false; // ✅ حالة التحميل

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: Colors.teal,
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedDate != null) {
      setState(() {
        dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  Future<void> _addUser() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => errorMessage = "يجب تعبئة جميع الحقول");
      return;
    }

    setState(() {
      errorMessage = "";
      _isLoading = true; // ✅ بدأ التحميل
    });

    try {
      final cred = await AuthService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      final appUser = AppUser(
        uid: cred.user!.uid,
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        dob: dateController.text,
        region: selectedRegion,
        address: addressController.text.trim(),
        phone: phoneController.text.trim(),
        nationalId: idController.text.trim(),
        role: 'user',
      );

      final map = appUser.toMap();
      map['createdAt'] = FieldValue.serverTimestamp();

      await AuthService.saveUserData(cred.user!.uid, map);
      // await AuthService.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تمت إضافة المستخدم بنجاح")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserManagementPage()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          errorMessage = 'هذا الإيميل مستخدم بالفعل.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'كلمة المرور ضعيفة.';
        } else {
          errorMessage = e.message ?? 'خطأ أثناء التسجيل.';
        }
      });
    } catch (e) {
      setState(() => errorMessage = 'حدث خطأ غير متوقع. حاول مرة أخرى.');
    } finally {
      setState(() => _isLoading = false); // ✅ انتهى التحميل
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
            colors: [Colors.white, Colors.teal.shade100],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.volunteer_activism,
                          color: Colors.amber, size: 60),
                      Text(
                        "إضافة مستخدم",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.teal),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserManagementPage()),
                        );
                      },
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ..._buildFormFields(),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: _isLoading
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.teal))
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _addUser,
                            child: const Text(
                              "إضافة",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      TextFormField(
        controller: nameController,
        decoration: const InputDecoration(
            labelText: "الاسم", prefixIcon: Icon(Icons.person)),
        validator: (value) => value!.isEmpty ? "الاسم مطلوب" : null,
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: emailController,
        decoration: const InputDecoration(
            labelText: "الإيميل", prefixIcon: Icon(Icons.email)),
        validator: (value) => value!.isEmpty ? "الإيميل مطلوب" : null,
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: passwordController,
        decoration: const InputDecoration(
            labelText: "كلمة المرور", prefixIcon: Icon(Icons.lock)),
        obscureText: true,
        validator: (value) => value!.isEmpty ? "كلمة المرور مطلوبة" : null,
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: dateController,
        readOnly: true,
        decoration: const InputDecoration(
            labelText: "تاريخ الميلاد", prefixIcon: Icon(Icons.calendar_today)),
        onTap: () => _selectDate(context),
        validator: (value) => value!.isEmpty ? "تاريخ الميلاد مطلوب" : null,
      ),
      const SizedBox(height: 10),
      DropdownButtonFormField<String>(
        decoration: const InputDecoration(
            labelText: "المنطقة", prefixIcon: Icon(Icons.location_city)),
        value: selectedRegion,
        items: saudiRegions
            .map((region) =>
                DropdownMenuItem(value: region, child: Text(region)))
            .toList(),
        onChanged: (value) => setState(() => selectedRegion = value),
        validator: (value) => value == null ? "اختر المنطقة" : null,
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: addressController,
        decoration: const InputDecoration(
            labelText: "العنوان", prefixIcon: Icon(Icons.home)),
        validator: (value) => value!.isEmpty ? "العنوان مطلوب" : null,
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: phoneController,
        decoration: const InputDecoration(
            labelText: "رقم الهاتف", prefixIcon: Icon(Icons.phone)),
      ),
      const SizedBox(height: 10),
      TextFormField(
        controller: idController,
        decoration: const InputDecoration(
            labelText: "رقم الهوية", prefixIcon: Icon(Icons.credit_card)),
        keyboardType: TextInputType.number,
        validator: (value) => value!.isEmpty ? "رقم الهوية مطلوب" : null,
      ),
    ];
  }
}
