import 'package:exakhairak_qreep/Association/association_add.dart';
import 'package:exakhairak_qreep/Association/association_administration.dart';
import 'package:flutter/material.dart';

class AssociationVolunteerPage extends StatefulWidget {
  const AssociationVolunteerPage({super.key});

  @override
  State<AssociationVolunteerPage> createState() =>
      _AssociationVolunteerPageState();
}

class _AssociationVolunteerPageState extends State<AssociationVolunteerPage> {
  bool _isAdding = false;
  bool _isManaging = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // خلفية متدرجة
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
                // صف علوي: زر رجوع + اسم الجمعية
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
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
                      "جمعية :",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
                const Icon(Icons.volunteer_activism,
                    color: Colors.teal, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "الحملات الموسمية",
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // صف الزرين: إضافة + إدارة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // زر إضافة حملة
                    ElevatedButton.icon(
                      onPressed: _isAdding
                          ? null
                          : () async {
                              setState(() => _isAdding = true);

                              // افتح صفحة الإضافة — قد تعيد null لو رجع المستخدم بدون حفظ
                              final result = await Navigator.push<
                                  List<Map<String, dynamic>>>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddCampaignPage(),
                                ),
                              );

                              // معالجة النتيجة بطريقة آمنة
                              if (result != null) {
                                // هنا يمكنك حفظ النتائج في حال أردت
                                // مثال: print(result);
                                // debugPrint('تمت إضافة الحملات: $result');
                              }

                              // توقف اللودنج بعد انتهاء العملية — تأكد من mounted
                              if (mounted) {
                                await Future.delayed(
                                    const Duration(milliseconds: 300));
                                setState(() => _isAdding = false);
                              }
                            },
                      icon: _isAdding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.add_circle_outline,
                              color: Colors.white),
                      label: _isAdding
                          ? const Text("", style: TextStyle(fontSize: 0))
                          : const Text(
                              "إضافة حملة",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),

                    // زر إدارة الحملات
                    ElevatedButton.icon(
                      onPressed: _isManaging
                          ? null
                          : () async {
                              setState(() => _isManaging = true);

                              // انتقل لصفحة الإدارة — لا تفترض أنها ستعيد قيمة
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ManageCampaignsPage(),
                                ),
                              );

                              if (mounted) {
                                await Future.delayed(
                                    const Duration(milliseconds: 300));
                                setState(() => _isManaging = false);
                              }
                            },
                      icon: _isManaging
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.settings, color: Colors.white),
                      label: _isManaging
                          ? const Text("", style: TextStyle(fontSize: 0))
                          : const Text(
                              "إدارة الحملات",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),
                const Text(
                  "اختر العملية التي ترغب بتنفيذها 👆",
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontStyle: FontStyle.italic),
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
