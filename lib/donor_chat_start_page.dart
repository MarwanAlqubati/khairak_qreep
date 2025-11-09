import 'package:flutter/material.dart';
import 'donor_chat_page.dart'; // صفحة الشات الرئيسية
import 'donor_home_page.dart'; // للرجوع إلى الرئيسية

class DonorChatStartPage extends StatelessWidget {
  final String donationType; // نوع التبرع (مالي - غذائي - ملابس - غير ذلك)
  final IconData icon; // الأيقونة الخاصة بالنوع
  final String beneficiaryName;
  final String phoneNumber;

  const DonorChatStartPage({
    super.key,
    required this.donationType,
    required this.icon,
    required this.beneficiaryName,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffe9fdfb),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // 🔹 زر الرجوع
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DonorHomePage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "الرجوع",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // 🔹 الكارد الذكي
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أيقونة حسب النوع
                        Icon(icon, color: Colors.teal, size: 70),
                        const SizedBox(height: 25),
                        Text(
                          "تبرعك $donationType جاهز للتواصل 💚",
                          style: TextStyle(
                            fontSize: 19,
                            color: Colors.teal.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "رقم جوال المستفيد:",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          phoneNumber,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 35),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DonorChatPage(
                                  beneficiaryName: beneficiaryName,
                                  phoneNumber: phoneNumber,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat, color: Colors.white),
                          label: const Text(
                            "فتح المحادثة",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
