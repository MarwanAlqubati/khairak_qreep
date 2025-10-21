import 'package:flutter/material.dart';
import 'donor_home_page.dart';
import 'donor_chat_start_page.dart';

class DonorDonationOtherPage extends StatefulWidget {
  const DonorDonationOtherPage({super.key});

  @override
  State<DonorDonationOtherPage> createState() => _DonorDonationOtherPageState();
}

class _DonorDonationOtherPageState extends State<DonorDonationOtherPage> {
  String? selectedCategory;
  String? selectedBeneficiary;

  final Map<String, List<String>> categoryBeneficiaries = {
    "أجهزة": ["مستفيد 001", "مستفيد 003"],
    "أثاث": ["مستفيد 002", "مستفيد 004"],
    "أدوات": ["مستفيد 005", "مستفيد 006"],
  };

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 الصف العلوي (الشعار + اسم المتبرع)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.volunteer_activism,
                        color: Colors.teal, size: 50),
                    const Text(
                      "المتبرع: أحمد",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
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

                const SizedBox(height: 30),

                // 🔹 العنوان الرئيسي
                Center(
                  child: Text(
                    "تبرعك الغِير ذلك",
                    style: TextStyle(
                      color: Colors.teal.shade700,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // ✅ القائمة الأولى (اختر فئة التبرع)
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "اختر فئة تبرعك:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFB2DFDB), // تركوازي فاتح
                        ),
                        child: DropdownButton<String>(
                          isExpanded: true,
                          underline: const SizedBox(),
                          alignment: Alignment.centerRight,
                          hint: const Text(
                            "اختر فئة التبرع",
                            style: TextStyle(fontSize: 17),
                          ),
                          value: selectedCategory,
                          items: categoryBeneficiaries.keys.map((String key) {
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  key,
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                              selectedBeneficiary = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ✅ القائمة الثانية (اختر المستفيد)
                if (selectedCategory != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "اختر المستفيد:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.grey.shade400, width: 1),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            underline: const SizedBox(),
                            alignment: Alignment.centerRight,
                            hint: const Text(
                              "اختر مستفيد",
                              style: TextStyle(fontSize: 17),
                            ),
                            value: selectedBeneficiary,
                            items: categoryBeneficiaries[selectedCategory]!
                                .map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    item,
                                    style: const TextStyle(fontSize: 17),
                                  ),
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
                  ),

                const Spacer(),

                // ✅ زر تأكيد التبرع
                Center(
                  child: SizedBox(
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
                                      donationType: "غير ذلك",
                                      icon: Icons.card_giftcard,
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
                          color: Colors.white, // ✅ النص أبيض
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
