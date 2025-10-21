import 'package:flutter/material.dart';
import 'beneficiary_page.dart';

class DonationFoodPage extends StatefulWidget {
  const DonationFoodPage({super.key});

  @override
  State<DonationFoodPage> createState() => _DonationFoodPageState();
}

class _DonationFoodPageState extends State<DonationFoodPage> {
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

                    // اسم المستفيد
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

              // 🔹 الشعار في المنتصف
              const Icon(Icons.volunteer_activism,
                  color: Colors.teal, size: 90),

              const SizedBox(height: 25),

              // 🔹 العنوان
              const Text(
                "طلب تبرع غذائي",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 50),

              // 🔹 الأزرار (الكاردات)
              Wrap(
                spacing: 30,
                runSpacing: 25,
                alignment: WrapAlignment.center,
                children: [
                  // رقم الطلب
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
                        width: 150,
                        height: 150,
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

                  // تقديم طلب
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
                            Icon(Icons.fastfood, size: 65, color: Colors.grey),
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

              // 🔹 الكاردات اللي تطلع تحت بعد الضغط (حجم أصغر)
              if (showRequestNumber) _buildInfoCard("رقم الطلب: 987654"),
              if (showRequestStatus)
                _buildInfoCard("✅ تم تقديم طلب تبرع غذائي بنجاح"),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 تصميم الكاردات اللي تظهر تحت (صغيرة ومنسقة)
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
              fontSize: 16, // 🔹 أصغر شوي
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
