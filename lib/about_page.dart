import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("حول التطبيق"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.volunteer_activism, color: Colors.teal, size: 100),
            const SizedBox(height: 20),
            const Text(
              "تطبيق خيرك قريب",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "منصة رقمية تربط المتبرعين بالمحتاجين عبر الموقع الجغرافي، "
              "لتسهيل عملية التبرع وتعزيز روح التعاون في المجتمع السعودي 🇸🇦.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "الفريق المطوّر:",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal),
            ),
            const SizedBox(height: 10),
            const Text(
              " فاطمة احمد العسيري,\ صالحه عبدالله عسيري, \البتول عايض ,\ بتول علي ال حوكاش",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Colors.black87),
            ),
            const Spacer(),
            const Divider(),
            const Text(
              "© 2025 خيرك قريب - جميع الحقوق محفوظة",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
