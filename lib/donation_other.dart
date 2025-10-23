import 'package:flutter/material.dart';
import 'beneficiary_page.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';

class DonationOtherPage extends StatefulWidget {
  const DonationOtherPage({super.key});

  @override
  State<DonationOtherPage> createState() => _DonationOtherPageState();
}

class _DonationOtherPageState extends State<DonationOtherPage> {
  bool showRequestNumber = false;
  bool showRequestStatus = false;
  String? selectedCategory;
  String? latestRequestNumber;
  bool isLoading = false; // متغير لتحديد حالة التحميل
  String? needid;
  @override
  void initState() {
    super.initState();
    _fetchNeedId();
  }

  Future<void> _fetchNeedId() async {
    final currentUser = AuthService.currentUser();
    if (currentUser != null) {
      setState(() {
        isLoading = true; // بدء التحميل
      });

      // الحصول على needid من بيانات المستخدم
      needid = currentUser.uid; // أو استخدم الخاصية المناسبة

      await Future.delayed(Duration(seconds: 1)); // محاكاة تحميل البيانات

      setState(() {
        isLoading = false; // الانتهاء من التحميل
      });
    } else {
      setState(() {
        isLoading = false; // الانتهاء من التحميل في حالة عدم وجود مستخدم
      });
    }
  }

  final List<String> categories = ["أجهزة", "أثاث", "أدوات"];

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
          child: Column(
            children: [
              // 🔹 الصف العلوي
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
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
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 الشعار والعنوان
              const Icon(Icons.volunteer_activism,
                  color: Colors.teal, size: 80),
              const SizedBox(height: 10),

              const Text(
                "طلب تبرع آخر",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 15),

              // 🔹 القائمة المنسدلة
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "اختر فئة:",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xffb9f2ed),
                        borderRadius: BorderRadius.circular(10),
                        border:
                            Border.all(color: Colors.teal.shade200, width: 1),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        dropdownColor: Colors.teal.shade50,
                        alignment: Alignment.centerRight,
                        hint: const Text(
                          "اختر نوع الفئة",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                        value: selectedCategory,
                        items: categories.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // 🔹 الكاردات
              Wrap(
                spacing: 30,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true; // بدء التحميل
                      });

                      final latestRequest = await RequestsService
                          .getLatestRequestByCategoryAndNeedId(
                              selectedCategory!, needid!);

                      if (latestRequest != null) {
                        setState(() {
                          latestRequestNumber = latestRequest.reqid;
                          showRequestNumber = true;
                          isLoading = false; // الانتهاء من التحميل
                        });
                      } else {
                        setState(() {
                          latestRequestNumber = "لا توجد طلبات سابقة";
                          showRequestNumber = true;
                          isLoading = false; // الانتهاء من التحميل
                        });
                      }

                      // إخفاء الرسالة بعد 5 ثوانٍ
                      await Future.delayed(Duration(seconds: 5));
                      setState(() {
                        showRequestNumber = false;
                      });
                    },
                    child: _buildCard(Icons.receipt_long, "رقم الطلب"),
                  ),
                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        isLoading = true; // بدء التحميل
                      });

                      // تنفيذ عملية تقديم الطلب
                      final request = AppRequest(
                        reqid: await RequestsService.generateUniqueReqId(),
                        needid: needid!, // يمكنك تخصيص هذا بناءً على الحاجة
                        description: 'طلب تبرع من فئة $selectedCategory',
                        category: selectedCategory!,
                      );

                      await RequestsService.addRequest(request);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("✅ تم تقديم الطلب بنجاح"),
                          backgroundColor: Colors.teal,
                          duration: const Duration(seconds: 2),
                        ),
                      );

                      // إخفاء الرسالة بعد 5 ثوانٍ
                      await Future.delayed(const Duration(seconds: 5));
                      setState(() {
                        showRequestStatus = false;
                        isLoading = false; // انتهاء التحميل
                      });
                    },
                    child: _buildCard(Icons.category, "تقديم طلب"),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              if (showRequestNumber)
                _buildInfoCard("رقم الطلب: ${latestRequestNumber ?? ''}"),
              if (showRequestStatus) _buildInfoCard("✅ تم تقديم الطلب بنجاح"),
              if (isLoading)
                const CircularProgressIndicator(), // عرض مؤشر التحميل
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(IconData icon, String title) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.grey),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
      child: Card(
        color: Colors.teal.shade50,
        elevation: 2,
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
