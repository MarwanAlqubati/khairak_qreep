import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/Services/charity_service.dart';
import 'package:exakhairak_qreep/models/app_Charity.dart';
import 'beneficiary_page.dart';

class BeneficiaryCampaignsPage extends StatefulWidget {
  const BeneficiaryCampaignsPage({super.key});

  @override
  State<BeneficiaryCampaignsPage> createState() =>
      _BeneficiaryCampaignsPageState();
}

class _BeneficiaryCampaignsPageState extends State<BeneficiaryCampaignsPage> {
  late Future<List<AppCharity>> _futureCampaigns;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  void _loadCampaigns() {
    setState(() {
      _futureCampaigns = CharityService.getStatsActive();
    });
  }

  // خريطة لتحويل اسم الأيقونة إلى IconData
  IconData _iconFromName(String? name) {
    if (name == null) return Icons.campaign;

    final n = name.toLowerCase();

    if (n.contains('school')) return Icons.school;
    if (n.contains('ac_unit')) return Icons.ac_unit;
    if (n.contains('fastfood')) return Icons.fastfood;
    if (n.contains('family_restroom')) return Icons.family_restroom;
    if (n.contains('volunteer')) return Icons.volunteer_activism;
    if (n.contains('hospital') || n.contains('local_hospital'))
      return Icons.local_hospital;
    if (n.contains('handshake')) return Icons.handshake;
    if (n.contains('favorite')) return Icons.favorite;
    if (n.contains('campaign')) return Icons.campaign;
    if (n.contains('food') || n.contains('bank')) return Icons.food_bank;
    if (n.contains('checkroom')) return Icons.checkroom;

    // لو الاسم كان نتيجة IconData.toString() نبحث عن كلمة مفتاحية
    if (n.contains('school')) return Icons.school;

    // افتراضي
    return Icons.campaign;
  }

  Future<void> _onRegisterTap(String title) async {
    // يمكن هنا إضافة منطق تسجيل حقيقي في حال أردت تخزين التسجيل
    // محاكاة انتظار ثم اظهار رسالة نجاح
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      Navigator.pop(context); // close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('تم التسجيل في $title بنجاح ✅'),
            backgroundColor: Colors.teal),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // صف العودة
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                      label: const Text("رجوع",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // العنوان
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "الحملات التطوعية المتاحة",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                ),

                const SizedBox(height: 20),

                // المحتوى: FutureBuilder مع RefreshIndicator
                Expanded(
                  child: FutureBuilder<List<AppCharity>>(
                    future: _futureCampaigns,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return RefreshIndicator(
                          onRefresh: () async => _loadCampaigns(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: Center(
                                    child: Text(
                                        'حدث خطأ أثناء التحميل: ${snapshot.error}')),
                              ),
                            ],
                          ),
                        );
                      }

                      final campaigns = snapshot.data ?? [];
                      if (campaigns.isEmpty) {
                        return RefreshIndicator(
                          onRefresh: () async => _loadCampaigns(),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(
                                  child: Text('لا توجد حملات متاحة حالياً.')),
                            ],
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          _loadCampaigns();
                          await _futureCampaigns;
                        },
                        child: ListView.builder(
                          itemCount: campaigns.length,
                          itemBuilder: (context, index) {
                            final c = campaigns[index];
                            final icon = _iconFromName(c.iconName);
                            final title = c.titlle ?? 'بدون عنوان';
                            final description = c.description ?? '';
                            final charityName = c.charityname ?? '';
                            final dateChar = c.datecharity ?? '';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(icon,
                                            color: Colors.teal, size: 40),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            title,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    if (description.isNotEmpty)
                                      Text(description,
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(fontSize: 15)),
                                    const SizedBox(height: 6),
                                    if (charityName.isNotEmpty)
                                      Text("📍 $charityName",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    if (dateChar.isNotEmpty)
                                      Text("🗓️ $dateChar",
                                          textAlign: TextAlign.right,
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton(
                                        onPressed: () => _onRegisterTap(title),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: const Text("تسجيل",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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
