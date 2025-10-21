import 'package:flutter/material.dart';
import 'login.dart';
import 'settings_page.dart'; // ✅ استدعاء صفحة الإعدادات
import 'about_page.dart'; // ✅ صفحة حول التطبيق

class AppDrawer extends StatelessWidget {
  final String userName;
  final String userRole; // "متبرع" أو "مستفيد" أو "جمعية"

  const AppDrawer({super.key, required this.userName, required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // ✅ رأس القائمة
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade300, Colors.teal.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            accountEmail: Text(
              userRole,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.teal, size: 40),
            ),
          ),

          // ✅ الإعدادات
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.teal),
            title: const Text(
              "الإعدادات",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),

          // ✅ حول التطبيق
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.teal),
            title: const Text(
              "حول التطبيق",
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutPage()),
              );
            },
          ),

          // ✅ الطلبات / التبرعات
          if (userRole == "مستفيد")
            ListTile(
              leading: const Icon(Icons.list_alt, color: Colors.teal),
              title: const Text(
                "طلباتي",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("سيتم عرض الطلبات قريباً 💚"),
                  ),
                );
              },
            ),

          if (userRole == "متبرع" || userRole == "جمعية")
            ListTile(
              leading: const Icon(Icons.volunteer_activism, color: Colors.teal),
              title: const Text(
                "تبرعاتي",
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("سيتم عرض التبرعات قريباً 💚"),
                  ),
                );
              },
            ),

          const Spacer(),
          const Divider(),

          // ✅ تسجيل الخروج
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "تسجيل الخروج",
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("تم تسجيل الخروج بنجاح"),
                  backgroundColor: Colors.teal,
                ),
              );
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                  (route) => false,
                );
              });
            },
          ),
        ],
      ),
    );
  }
}
