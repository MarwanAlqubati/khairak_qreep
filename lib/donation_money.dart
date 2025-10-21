import 'package:flutter/material.dart';
import 'beneficiary_page.dart';

class DonationMoneyPage extends StatefulWidget {
  const DonationMoneyPage({super.key});

  @override
  State<DonationMoneyPage> createState() => _DonationMoneyPageState();
}

class _DonationMoneyPageState extends State<DonationMoneyPage> {
  bool showRequestNumber = false;
  bool showRequestStatus = false;
  final TextEditingController _amountController = TextEditingController();
  String? submittedAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.teal.shade50],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 🔹 الصف العلوي (زر رجوع + اسم المستفيد)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BeneficiaryPage()),
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
                      "المستفيد: 001",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 الشعار
                const Icon(Icons.volunteer_activism,
                    color: Colors.teal, size: 80),
                const SizedBox(height: 15),

                // 🔹 العنوان
                const Text(
                  "طلب تبرع مالي",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 حقل المبلغ المطلوب
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "أدخل المبلغ المطلوب (بالريال)",
                      prefixIcon: const Icon(Icons.money, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.teal.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            const BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 الكاردات (زرين رقم الطلب وتقديم الطلب)
                Wrap(
                  spacing: 30,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          showRequestNumber = !showRequestNumber;
                        });
                      },
                      child: _buildCard(Icons.receipt_long, "رقم الطلب"),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (_amountController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("الرجاء إدخال المبلغ المطلوب 💰"),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          submittedAmount = _amountController.text;
                          showRequestStatus = true;
                          showRequestNumber = true;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "✅ تم إرسال طلب بمبلغ ${_amountController.text} ريال"),
                            backgroundColor: Colors.teal,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: _buildCard(Icons.note_add, "تقديم طلب"),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // 🔹 الكاردات اللي تظهر تحت بعد الضغط
                if (showRequestNumber) _buildInfoCard("رقم الطلب: 123456"),
                if (showRequestStatus)
                  _buildInfoCard(
                      "✅ تم تقديم طلب تبرع مالي بمبلغ ${submittedAmount ?? ''} ريال بنجاح"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 تصميم الكاردات (الأزرار)
  Widget _buildCard(IconData icon, String title) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 تصميم الكاردات اللي تظهر تحت
  Widget _buildInfoCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 6),
      child: Card(
        color: Colors.teal.shade50,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
