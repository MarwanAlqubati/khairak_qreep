import 'package:flutter/material.dart';
import 'beneficiary_page.dart';

class DonationClothesPage extends StatefulWidget {
  const DonationClothesPage({super.key});

  @override
  State<DonationClothesPage> createState() => _DonationClothesPageState();
}

class _DonationClothesPageState extends State<DonationClothesPage> {
  bool showRequestNumber = false;
  bool showRequestStatus = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ خلفية متدرجة مثل باقي الصفحات
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
          child: Column(
            children: [
              // 🔹 الصف العلوي (زر رجوع + اسم المستفيد)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // ✅ زر الرجوع بنفس شكل زر المتبرع
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
              ),

              const SizedBox(height: 60), // 🔹 نزلنا المحتوى لتحت

              const Icon(Icons.volunteer_activism,
                  color: Colors.teal, size: 90),
              const SizedBox(height: 25),

              const Text(
                "طلب تبرع ملابس",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 50),

              Wrap(
                spacing: 30,
                runSpacing: 25,
                alignment: WrapAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showRequestNumber = !showRequestNumber;
                      });
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        width: 160,
                        height: 160,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.receipt_long,
                                size: 65, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "رقم الطلب",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showRequestStatus = !showRequestStatus;
                      });
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        width: 150,
                        height: 150,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.checkroom, size: 65, color: Colors.grey),
                            SizedBox(height: 10),
                            Text(
                              "تقديم طلب",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // 🔹 الكاردات اللي تطلع تحت بعد الضغط (صغيرة ومنسقة)
              if (showRequestNumber) _buildInfoCard("رقم الطلب: 456789"),
              if (showRequestStatus)
                _buildInfoCard("✅ تم تقديم طلب تبرع ملابس بنجاح"),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 الكاردات الصغيرة اللي تطلع بعد الضغط
  Widget _buildInfoCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
      child: Card(
        color: Colors.teal.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
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
