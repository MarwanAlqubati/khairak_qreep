import 'package:flutter/material.dart';
import 'donation_money.dart';
import 'donation_food.dart';
import 'donation_clothes.dart';
import 'donation_other.dart';
import 'track_requests.dart';
import 'home.dart';
import 'beneficiary_campaigns_page.dart';
import 'app_drawer.dart'; 

class BeneficiaryPage extends StatelessWidget {
  const BeneficiaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(
        userName: "المستفيد 001",
        userRole: "مستفيد",
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

                const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: Text(
                      "المستفيد: 001",
                      style: TextStyle(
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DonationMoneyPage()),
                              );
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.fastfood,
                            label: "تبرع غذائي",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DonationFoodPage()),
                              );
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.checkroom,
                            label: "تبرع ملابس",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const DonationClothesPage()),
                              );
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.card_giftcard,
                            label: "غير ذلك",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const DonationOtherPage()),
                              );
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.track_changes,
                            label: "متابعة الطلبات",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrackRequestsPage()),
                              );
                            },
                          ),
                          _buildDonationCard(
                            context,
                            icon: Icons.handshake,
                            label: "الحملات التطوعية",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        const BeneficiaryCampaignsPage()),
                              );
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
