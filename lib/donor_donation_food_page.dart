import 'package:flutter/material.dart';
import 'donor_home_page.dart';
import 'donor_chat_start_page.dart';

class DonorDonationFoodPage extends StatefulWidget {
  const DonorDonationFoodPage({super.key});

  @override
  State<DonorDonationFoodPage> createState() => _DonorDonationFoodPageState();
}

class _DonorDonationFoodPageState extends State<DonorDonationFoodPage> {
  final List<String> beneficiaries = [
    'مستفيد 010',
    'مستفيد 011',
    'مستفيد 012',
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
                // 🔹 الشعار واسم المتبرع
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.volunteer_activism,
                        color: Colors.teal, size: 50),
                    Text(" المتبرع: أحمد",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 زر الرجوع (تم التعديل هنا)
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DonorHomePage(donorName: "أحمد"),
                        ),
                        (route) => false, // 🔸 يحذف كل الصفحات قبلها
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
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Center(
                  child: Text("تبرعك الغذائي",
                      style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ),

                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text("اختر المستفيد:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                ),

                const SizedBox(height: 12),

                // 🔹 القائمة المنسدلة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1),
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
                          child:
                              Text(item, style: const TextStyle(fontSize: 17)),
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

                const Spacer(),

                // 🔹 زر تأكيد التبرع
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
                                  'تم تأكيد التبرع الغذائي لـ $selectedBeneficiary 💚',
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
                                    donationType: "غذائي",
                                    icon: Icons.fastfood,
                                    beneficiaryName: selectedBeneficiary!,
                                    phoneNumber: "0559876543",
                                  ),
                                ),
                              );
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text(
                      "تأكيد التبرع",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
