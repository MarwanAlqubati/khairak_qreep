import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  String selectedLanguage = "العربية";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "البيانات الشخصية",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const ListTile(
            leading: Icon(Icons.person, color: Colors.teal),
            title: Text("الاسم: "),
          ),
          const ListTile(
            leading: Icon(Icons.phone, color: Colors.teal),
            title: Text("رقم الجوال: 0551234567"),
          ),
          const ListTile(
            leading: Icon(Icons.location_city, color: Colors.teal),
            title: Text("المدينة: جدة"),
          ),
          const Divider(height: 30),

          // 🔸 الإشعارات
          SwitchListTile(
            title: const Text("تفعيل الإشعارات"),
            value: notificationsEnabled,
            activeColor: Colors.teal,
            onChanged: (value) {
              setState(() => notificationsEnabled = value);
            },
          ),

          const Divider(height: 30),

          // 🔸 اللغة
          ListTile(
            leading: const Icon(Icons.language, color: Colors.teal),
            title: const Text("اللغة"),
            trailing: DropdownButton<String>(
              value: selectedLanguage,
              items: ["العربية", "English"].map((lang) {
                return DropdownMenuItem<String>(
                  value: lang,
                  child: Text(lang),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedLanguage = value!);
              },
            ),
          ),

          const Divider(height: 30),

          // 🔸 الدعم الفني
          ListTile(
            leading: const Icon(Icons.support_agent, color: Colors.teal),
            title: const Text("تواصل مع الدعم"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("سيتم تحويلك إلى الدعم قريباً 💬")),
              );
            },
          ),
        ],
      ),
    );
  }
}
