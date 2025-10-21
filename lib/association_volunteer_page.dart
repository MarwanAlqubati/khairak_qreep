import 'package:flutter/material.dart';

class AssociationVolunteerPage extends StatelessWidget {
  const AssociationVolunteerPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 قائمة الحملات (مؤقتًا ثابتة، لاحقًا من قاعدة البيانات)
    final List<Map<String, dynamic>> campaigns = [
      {
        "title": "حملة العودة للمدارس",
        "icon": Icons.school,
      },
      {
        "title": "حملة دفء الشتاء",
        "icon": Icons.ac_unit,
      },
      {
        "title": "حملة إفطار صائم",
        "icon": Icons.fastfood,
      },
    ];

    return Scaffold(
      body: Container(
        // 🔹 خلفية متدرجة بين الأبيض والتركوازي الفاتح
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
                // 🔹 الصف العلوي (زر رجوع + اسم الجمعية)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
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
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const Text(
                      "جمعية :",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 🔹 الشعار
                const Icon(Icons.volunteer_activism,
                    color: Colors.teal, size: 80),

                const SizedBox(height: 20),

                // 🔹 العنوان الرئيسي
                const Text(
                  "الحملات الموسمية",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // 🔹 قائمة الإعلانات (الكاردات)
                Expanded(
                  child: ListView.builder(
                    itemCount: campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaigns[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(campaign["icon"],
                                      color: Colors.teal, size: 40),
                                  const SizedBox(width: 15),
                                  Text(
                                    campaign["title"],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم تسجيل ${campaign["title"]} كإعلان ✅',
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
