import 'package:flutter/material.dart';
import 'beneficiary_page.dart';
import 'chat_page.dart'; // 🔹 تأكدي من وجود هذا الملف (صفحة المحادثة)

class TrackRequestsPage extends StatelessWidget {
  const TrackRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ زر الرجوع + اسم المستفيد (بالتصميم الموحّد)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 زر الرجوع بنفس التصميم الموحد
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

                    // 🔹 اسم المستفيد
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

              // 🔹 الشعار
              const Icon(Icons.volunteer_activism,
                  size: 70, color: Colors.teal),
              const SizedBox(height: 20),

              // 🔹 العنوان
              const Text(
                "متابعة الطلبات",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber),
              ),
              const SizedBox(height: 20),

              // 🔹 مثال على الطلبات (لاحقاً تُعرض من قاعدة البيانات)
              Expanded(
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  children: [
                    _buildRequestCard(
                      context,
                      title: "طلب مالي",
                      status: "تم الاستلام",
                    ),
                    const SizedBox(height: 16),
                    _buildRequestCard(
                      context,
                      title: "طلب ملابس",
                      status: "قيد التسليم",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 كارد الطلب الواحد
  Widget _buildRequestCard(BuildContext context,
      {required String title, required String status}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        status == "تم الاستلام" ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ✅ زر المحادثة يظهر فقط عندما تكون الحالة "تم الاستلام"
            if (status == "تم الاستلام")
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChatPage(userName: "المتبرع"),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    "تواصل مع المتبرع",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
