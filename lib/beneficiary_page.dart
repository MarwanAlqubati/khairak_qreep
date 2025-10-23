import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'donation_money.dart';
import 'donation_food.dart';
import 'donation_clothes.dart';
import 'donation_other.dart';
import 'track_requests.dart';
import 'home.dart';
import 'beneficiary_campaigns_page.dart';
import 'app_drawer.dart';

class BeneficiaryPage extends StatefulWidget {
  const BeneficiaryPage({super.key});

  @override
  State<BeneficiaryPage> createState() => _BeneficiaryPageState();
}

class _BeneficiaryPageState extends State<BeneficiaryPage> {
  String? userName;
  String? userRole;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.currentUser();

      final uid = user!.uid;
      final doc = await AuthService.getUserDoc(uid);

      setState(() {
        userName = doc['name'] ?? 'مستخدم غير معروف';
        isLoading = false;
      });
    } catch (e) {
      debugPrint('خطأ في تحميل بيانات المستخدم: $e');
      setState(() {
        userName = 'خطأ في تحميل البيانات';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.teal),
        ),
      );
    }

    return Scaffold(
      drawer: AppDrawer(
        userName: userName ?? "المستفيد",
        userRole: userRole ?? "مستفيد",
      ),
      body: Builder(
        builder: (context) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.teal.shade50,
                Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.teal, size: 35),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoPage()),
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
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: Text(
                      " ${userName ?? 'غير معروف'}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Icon(Icons.volunteer_activism,
                    color: Colors.teal, size: 70),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Wrap(
                        spacing: 30,
                        runSpacing: 30,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildDonationCard(
                            context,
                            icon: Icons.attach_money,
                            label: "تبرع مالي",
                            onTap: () async {
                              await _navigateToPage(const DonationMoneyPage());
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.fastfood,
                            label: "تبرع غذائي",
                            onTap: () async {
                              await _navigateToPage(const DonationFoodPage());
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.checkroom,
                            label: "تبرع ملابس",
                            onTap: () async {
                              await _navigateToPage(
                                  const DonationClothesPage());
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.card_giftcard,
                            label: "غير ذلك",
                            onTap: () async {
                              await _navigateToPage(const DonationOtherPage());
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.track_changes,
                            label: "متابعة الطلبات",
                            onTap: () async {
                              await _navigateToPage(const TrackRequestsPage());
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.handshake,
                            label: "الحملات التطوعية",
                            onTap: () async {
                              await _navigateToPage(
                                  const BeneficiaryCampaignsPage());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToPage(Widget page) async {
    // عرض مؤشر التحميل أثناء الانتقال إلى الصفحة الجديدة
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // الانتظار لفترة قصيرة لمحاكاة التحميل
    await Future.delayed(const Duration(milliseconds: 500));

    // الانتقال إلى الصفحة الجديدة
    Navigator.pop(context); // إغلاق مؤشر التحميل
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Widget _buildDonationCard(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.teal),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
