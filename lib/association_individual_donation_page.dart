import 'package:exakhairak_qreep/Chat/users_list_screen.dart';
import 'package:flutter/material.dart';
import 'association_page.dart'; // ✅ نضيف هذا عشان نرجع لصفحة الجمعيات

class AssociationIndividualDonationPage extends StatefulWidget {
  const AssociationIndividualDonationPage({super.key});

  @override
  State<AssociationIndividualDonationPage> createState() =>
      _AssociationIndividualDonationPageState();
}

class _AssociationIndividualDonationPageState
    extends State<AssociationIndividualDonationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // خلفية متدرجة بين الأبيض والتركوازي الفاتح
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
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 الصف العلوي (زر الرجوع + اسم الجمعية)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر الرجوع
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AssociationPage(), // ← اسم الجمعية
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "رجوع",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),

                    const Text(
                      "الجمعية",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // 🔹 الشعار بالأعلى
                const Icon(Icons.volunteer_activism,
                    color: Colors.teal, size: 80),

                const SizedBox(height: 25),

                // 🔹 العنوان الرئيسي
                const Text(
                  "تبرع فردي",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 30),
                SizedBox(height: 10),
                Text(
                  'ابدأ بتحديد المستفيد للتبرع الفردي',
                  style: TextStyle(fontSize: 18, color: Colors.teal),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UsersListScreen()),
                    );
                  },
                  child: Text(
                    'بدء تبرع جديدة',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 20),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
