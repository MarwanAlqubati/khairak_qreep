import 'package:flutter/material.dart';
import 'association_chat_page.dart'; // صفحة الشات
import 'association_page.dart'; // ✅ نضيف هذا عشان نرجع لصفحة الجمعيات

class AssociationIndividualDonationPage extends StatefulWidget {
  const AssociationIndividualDonationPage({super.key});

  @override
  State<AssociationIndividualDonationPage> createState() =>
      _AssociationIndividualDonationPageState();
}

class _AssociationIndividualDonationPageState
    extends State<AssociationIndividualDonationPage> {
  String? selectedBeneficiary;

  // 🔹 مؤقتًا – المستفيدين من قاعدة البيانات لاحقًا
  final List<Map<String, String>> beneficiaries = [
    {"id": "001", "name": "مستفيد "},
    {"id": "002", "name": "مستفيد "},
    {"id": "003", "name": "مستفيد "},
    {"id": "004", "name": "مستفيد "},
  ];

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
                            builder: (_) => const AssociationPage(
                                associationName: "جمعية"), // ← اسم الجمعية
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

                // 🔹 قائمة المستفيدين
                Expanded(
                  child: ListView.builder(
                    itemCount: beneficiaries.length,
                    itemBuilder: (context, index) {
                      final beneficiary = beneficiaries[index];
                      final isSelected =
                          selectedBeneficiary == beneficiary["id"];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedBeneficiary = beneficiary["id"];
                          });
                        },
                        child: Card(
                          color:
                              isSelected ? Colors.teal.shade50 : Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.person,
                                color: Colors.grey, size: 35),
                            title: Text(
                              beneficiary["name"]!,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected ? Colors.teal : Colors.black87,
                              ),
                            ),
                            trailing: Text(
                              beneficiary["id"]!,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.teal
                                    : Colors.grey.shade600,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 زر إكمال
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedBeneficiary == null
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssociationChatPage(
                                  beneficiaryId: selectedBeneficiary!,
                                  beneficiaryName: beneficiaries.firstWhere(
                                      (b) =>
                                          b["id"] ==
                                          selectedBeneficiary)["name"]!,
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "أكمل",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
