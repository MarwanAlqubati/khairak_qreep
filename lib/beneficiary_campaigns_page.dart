import 'package:flutter/material.dart';
import 'beneficiary_page.dart';

class BeneficiaryCampaignsPage extends StatelessWidget {
  const BeneficiaryCampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> campaigns = [
      {
        "title": "حملة العودة للمدارس",
        "icon": Icons.school,
        "desc": "جمع أدوات مدرسية للطلاب المحتاجين.",
        "org": "جمعية البر الخيرية",
        "date": "من 10 إلى 25 أغسطس"
      },
      {
        "title": "حملة دفء الشتاء",
        "icon": Icons.ac_unit,
        "desc": "توزيع بطانيات وملابس شتوية.",
        "org": "جمعية الإحسان",
        "date": "من 1 إلى 20 ديسمبر"
      },
      {
        "title": "حملة إفطار صائم",
        "icon": Icons.fastfood,
        "desc": "توزيع وجبات إفطار للصائمين في رمضان.",
        "org": "جمعية الإكرام",
        "date": "شهر رمضان المبارك"
      },
    ];

    return Scaffold(
      body: Container(
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
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // 🔹 الصف العلوي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BeneficiaryPage(),
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
                      "المستفيد: 001",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 العنوان
                const Text(
                  "الحملات التطوعية المتاحة",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 قائمة الحملات
                Expanded(
                  child: ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Icon(campaign["icon"],
                                      color: Colors.teal, size: 40),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      campaign["title"],
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                campaign["desc"],
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "📍 ${campaign["org"]}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              Text(
                                "🗓️ ${campaign["date"]}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: ElevatedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "تم التسجيل في ${campaign["title"]} بنجاح ✅",
                                        ),
                                        backgroundColor: Colors.teal,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    "تسجيل",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
