import 'package:flutter/material.dart';
import 'beneficiary_details.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';

class AccessControlPage extends StatefulWidget {
  const AccessControlPage({super.key});

  @override
  State<AccessControlPage> createState() => _AccessControlPageState();
}

class _AccessControlPageState extends State<AccessControlPage> {
  final TextEditingController searchController = TextEditingController();

  List<AppUser> allUsers = [];
  List<AppUser> filteredUsers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AuthService.getAllUsersExceptCurrent();
      setState(() {
        allUsers = users;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading users: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchByNationalId() {
    final query = searchController.text.trim();
    setState(() {
      if (query.isEmpty) {
        filteredUsers = allUsers;
      } else {
        filteredUsers = allUsers
            .where((user) =>
                (user.nationalId ?? '').contains(query) ||
                user.name.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.teal.shade100],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ الشعار والزر العلوي
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
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
                            horizontal: 18, vertical: 10),
                      ),
                    ),
                    const Icon(
                      Icons.volunteer_activism,
                      color: Colors.amber,
                      size: 70,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "قائمة المستفيدين",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 15),

              // 🔍 حقل البحث
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          labelText: "ابحث برقم الهوية أو الاسم",
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.teal),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: searchByNationalId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.search,
                          color: Colors.white, size: 26),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 📋 عرض النتائج
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.teal),
                      )
                    : filteredUsers.isEmpty
                        ? const Center(
                            child: Text(
                              "لا يوجد مستخدمين متاحين",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredUsers.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return Card(
                                color: Colors.white,
                                elevation: 4,
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.person,
                                    color: Colors.amber,
                                    size: 35,
                                  ),
                                  title: Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                    ),
                                  ),
                                  subtitle: Text(
                                    "رقم الهوية: ${user.nationalId ?? 'غير متوفر'}\n"
                                    "البريد: ${user.email}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BeneficiaryDetailPage(
                                          name: user.name,
                                          phone: user.region ?? '',
                                          nationalId: user.nationalId ?? '',
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
    );
  }
}
