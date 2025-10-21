import 'package:flutter/material.dart';
import 'donor_home_page.dart';
import 'donor_chat_start_page.dart'; // صفحة الكارد الذكية

class DonorDonationMoneyPage extends StatefulWidget {
  const DonorDonationMoneyPage({super.key});

  @override
  State<DonorDonationMoneyPage> createState() => _DonorDonationMoneyPageState();
}

class _DonorDonationMoneyPageState extends State<DonorDonationMoneyPage> {
  final List<String> beneficiaries = [
    'مستفيد 001',
    'مستفيد 002',
    'مستفيد 003',
  ];

  String? selectedBeneficiary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffe9fdfb), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 الهيدر
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.volunteer_activism,
                        color: Colors.teal, size: 50),
                    Text(
                      " المتبرع: أحمد",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 زر الرجوع
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DonorHomePage(donorName: "أحمد"),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "الرجوع",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 العنوان
                Center(
                  child: Text(
                    "تبرعك المالي",
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🔹 اختيار المستفيد
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "اختر المستفيد:",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        alignment: Alignment.centerRight,
                        hint: const Text(":اختر مستفيد",
                            style: TextStyle(fontSize: 17)),
                        value: selectedBeneficiary,
                        items: beneficiaries.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(item,
                                  style: const TextStyle(fontSize: 17)),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedBeneficiary = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 🔹 زر التأكيد
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: selectedBeneficiary == null
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'تم تأكيد التبرع لـ $selectedBeneficiary بنجاح 💚',
                                ),
                                backgroundColor: Colors.teal,
                                duration: const Duration(seconds: 2),
                              ),
                            );

                            Future.delayed(const Duration(seconds: 2), () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DonorChatStartPage(
                                    donationType: "مالي",
                                    icon: Icons.attach_money,
                                    beneficiaryName: selectedBeneficiary!,
                                    phoneNumber: "0501234567",
                                  ),
                                ),
                              );
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "تأكيد التبرع",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // ✅ النص صار أبيض
                      ),
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
