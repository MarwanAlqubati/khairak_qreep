import 'package:flutter/material.dart';
import 'home.dart';
import 'donor_donation_money_page.dart';
import 'donor_donation_food_page.dart';
import 'donor_donation_clothes_page.dart';
import 'donor_donation_other_page.dart';
import 'app_drawer.dart'; // ✅ القائمة الجانبية

class DonorHomePage extends StatelessWidget {
  final String donorName;

  const DonorHomePage({super.key, required this.donorName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(userName: "أحمد", userRole: "متبرع"), // ✅ القائمة
      body: Builder(
        builder: (context) => Container(
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ الصف العلوي: الشعار + زر القائمة + الاسم
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // زر القائمة الجانبية
                      IconButton(
                        icon: const Icon(Icons.menu,
                            color: Colors.teal, size: 35),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                      ),

                      const Icon(
                        Icons.volunteer_activism,
                        color: Colors.teal,
                        size: 60,
                      ),
                    ],
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'المتبرع: $donorName',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal.shade700,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "الرجوع",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                    ),
                  ),

                  const Spacer(),

                  Center(
                    child: SizedBox(
                      height: 400,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 25,
                        crossAxisSpacing: 25,
                        children: [
                          _buildCard(
                            context,
                            icon: Icons.attach_money,
                            title: 'تبرع مالي',
                            page: const DonorDonationMoneyPage(),
                          ),
                          _buildCard(
                            context,
                            icon: Icons.fastfood,
                            title: 'تبرع غذائي',
                            page: const DonorDonationFoodPage(),
                          ),
                          _buildCard(
                            context,
                            icon: Icons.checkroom,
                            title: 'تبرع ملابس',
                            page: const DonorDonationClothesPage(),
                          ),
                          _buildCard(
                            context,
                            icon: Icons.card_giftcard,
                            title: 'غير ذلك',
                            page: const DonorDonationOtherPage(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required IconData icon, required String title, required Widget page}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.teal.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(2, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.teal, size: 60),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFFFFC107),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
