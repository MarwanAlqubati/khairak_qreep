// lib/pages/beneficiary_campaigns_page.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/Services/charity_service.dart';
import 'package:exakhairak_qreep/Services/registration_service.dart';
import 'package:exakhairak_qreep/models/app_Charity.dart';
import 'package:exakhairak_qreep/models/app_campaign_registration.dart';
import 'beneficiary_page.dart';

class BeneficiaryCampaignsPage extends StatefulWidget {
  const BeneficiaryCampaignsPage({super.key});

  @override
  State<BeneficiaryCampaignsPage> createState() =>
      _BeneficiaryCampaignsPageState();
}

class _BeneficiaryCampaignsPageState extends State<BeneficiaryCampaignsPage> {
  late Future<List<AppCharity>> _futureCampaigns;
  final Set<String> _registeredCampaignIds = {};
  bool _loadingRegistered = true;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
    _loadRegisteredCampaigns(); // حمل الحملات المسجلة للمستخدم
  }

  void _loadCampaigns() {
    setState(() {
      _futureCampaigns = CharityService.getStatsActive();
    });
  }

  Future<void> _loadRegisteredCampaigns() async {
    setState(() {
      _loadingRegistered = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // لم يسجل الدخول -> لا شيء
      setState(() {
        _registeredCampaignIds.clear();
        _loadingRegistered = false;
      });
      return;
    }

    final ids =
        await RegistrationService.getRegisteredCampaignIdsForUser(user.uid);
    setState(() {
      _registeredCampaignIds
        ..clear()
        ..addAll(ids);
      _loadingRegistered = false;
    });
  }

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
    return Icons.campaign;
  }

  Future<Map<String, String>> _getCurrentUserInfo() async {
    // return { 'userId': 'xxx', 'userName': 'YYY' }
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {'userId': '', 'userName': ''};

    String userName = user.displayName ?? '';

    // لو الاسم غير موجود في profile، حاول جلبه من collection users (اختياري)
    if (userName.isEmpty) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();
        if (data != null) {
          userName = (data['username'] ?? data['name'] ?? '') as String;
        }
      } catch (_) {
        // تجاهل الخطأ وابقِ displayName كـ ''
      }
    }

    // fallback إلى البريد إن لم يوجد اسم
    if (userName.isEmpty) userName = user.email ?? 'مستخدم';

    return {'userId': user.uid, 'userName': userName};
  }

  Future<void> _onRegisterTap(AppCharity c) async {
    final id = c.uid ?? '';
    final title = c.titlle ?? 'بدون عنوان';
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ: معرّف الحملة غير موجود')),
      );
      return;
    }

    final userInfo = await _getCurrentUserInfo();
    final userId = userInfo['userId']!;
    final userName = userInfo['userName']!;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')),
      );
      return;
    }

    // تحقق سريع محلي إن كان موجوداً بالفعل في ال set
    if (_registeredCampaignIds.contains(id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('أنت مسجل بالفعل في "$title"')),
      );
      return;
    }

    // اظهار مؤشر تحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await RegistrationService.registerUser(
        campaignId: id,
        campaignTitle: title,
        userId: userId,
        userName: userName,
      );

      // اغلاق الـ dialog
      if (mounted) Navigator.pop(context);

      // حدث الواجهة: اضف الـ id للمجموعة
      setState(() {
        _registeredCampaignIds.add(id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم التسجيل في "$title" بنجاح ✅')),
      );
    } on Exception catch (e) {
      if (mounted) Navigator.pop(context); // اغلاق الـ dialog
      if (e.toString().contains('already_registered')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('أنت مسجل بالفعل في "$title"')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التسجيل: ${e.toString()}')),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
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

                Expanded(
                  child: FutureBuilder<List<AppCharity>>(
                    future: _futureCampaigns,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return RefreshIndicator(
                          onRefresh: () async {
                            _loadCampaigns();
                            await _futureCampaigns;
                            await _loadRegisteredCampaigns();
                          },
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
                          onRefresh: () async {
                            _loadCampaigns();
                            await _futureCampaigns;
                            await _loadRegisteredCampaigns();
                          },
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
                          await _loadRegisteredCampaigns();
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
                            final id = c.uid ?? '';

                            final isRegistered =
                                _registeredCampaignIds.contains(id);

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
                                        onPressed: isRegistered
                                            ? null
                                            : () => _onRegisterTap(c),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isRegistered
                                              ? Colors.grey
                                              : Colors.teal,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                        child: Text(
                                            isRegistered ? "مسجل" : "تسجيل",
                                            style: const TextStyle(
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
