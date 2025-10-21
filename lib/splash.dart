import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: Stack(
          children: [
            Positioned(
              top: -40,
              left: -30,
              child: _buildCircle(130, Colors.teal.shade200),
            ),
            Positioned(
              top: 100,
              right: -50,
              child: _buildCircle(160, Colors.white.withOpacity(0.8)),
            ),
            Positioned(
              bottom: 130,
              left: -40,
              child: _buildCircle(110, Colors.teal.shade300.withOpacity(0.6)),
            ),
            Positioned(
              bottom: -30,
              right: -30,
              child: _buildCircle(150, Colors.teal.shade200.withOpacity(0.7)),
            ),
            Positioned(
              top: 320,
              left: 90,
              child: _buildCircle(60, Colors.white.withOpacity(0.6)),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volunteer_activism,
                      size: 100, color: Colors.teal),
                  const SizedBox(height: 20),
                  const Text(
                    'خيرك قريب',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'يدك للخير ممدودة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 60),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 15,
                      ),
                    ),
                    // ✅ الآن الزر يفتح صفحة تسجيل الدخول
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'ابدأ الآن',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.9),
      ),
    );
  }
}
