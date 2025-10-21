import 'package:flutter/material.dart';
import 'users_management.dart';

class DeleteUserPage extends StatefulWidget {
  @override
  _DeleteUserPageState createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final TextEditingController idSearchController = TextEditingController();

  // مثال بيانات محلية مؤقتة (تقدر تربطها لاحقاً بالـ Firebase)
  List<Map<String, String>> users = [
    {
      'name': 'أحمد علي',
      'phone': '+966500000001',
      'nationalId': '1116725316',
      'email': 'ahmad@example.com',
    },
    {
      'name': 'سارة محمد',
      'phone': '+966500000002',
      'nationalId': '2226725317',
      'email': 'sara@example.com',
    },
    {
      'name': 'محمد خالد',
      'phone': '+966500000003',
      'nationalId': '3336725318',
      'email': 'mohammed@example.com',
    },
  ];

  Map<String, String>? foundUser;
  String infoMessage = "";

  void _searchById() {
    final query = idSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        foundUser = null;
        infoMessage = "أدخل رقم الهوية للبحث";
      });
      return;
    }

    final match =
        users.firstWhere((u) => u['nationalId'] == query, orElse: () => {});
    if (match.isNotEmpty) {
      setState(() {
        foundUser = match;
        infoMessage = "";
      });
    } else {
      setState(() {
        foundUser = null;
        infoMessage = "لم يتم العثور على مستخدم برقم الهوية هذا";
      });
    }
  }

  void _deleteFoundUser() {
    if (foundUser == null) return;
    final idToDelete = foundUser!['nationalId']!;
    setState(() {
      users.removeWhere((u) => u['nationalId'] == idToDelete);
      foundUser = null;
      idSearchController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("تم حذف المستخدم برقم الهوية $idToDelete")),
    );

    // الرجوع إلى صفحة إدارة المستخدمين بعد حذف (مثل سلوك سابق)
    Future.delayed(const Duration(milliseconds: 700), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserManagementPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نفس الخلفية المتدرجة مثل باقي الصفحات
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.teal.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // رأس الصفحة: شعار + عنوان
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(
                      Icons.volunteer_activism,
                      color: Colors.amber,
                      size: 60,
                    ),
                    Text(
                      "حذف مستخدم",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ],
                ),
              ),

              // زر الرجوع (كما كان)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.teal),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserManagementPage()),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // حق البحث برقم الهوية
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    TextField(
                      controller: idSearchController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "ابحث برقم الهوية",
                        hintText: "مثال: 1116725316",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon:
                            const Icon(Icons.search, color: Colors.teal),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            idSearchController.clear();
                            setState(() {
                              foundUser = null;
                              infoMessage = "";
                            });
                          },
                        ),
                      ),
                      onSubmitted: (_) => _searchById(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.search),
                        label: const Text("بحث"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _searchById,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (infoMessage.isNotEmpty)
                      Text(
                        infoMessage,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 14),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // إذا تم العثور على مستخدم، اعرض بياناته وبزر الحذف
              if (foundUser != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.teal, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  foundUser!['name'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text("الإيميل: ${foundUser!['email'] ?? '-'}"),
                          const SizedBox(height: 4),
                          Text("الجوال: ${foundUser!['phone'] ?? '-'}"),
                          const SizedBox(height: 4),
                          Text(
                              "رقم الهوية: ${foundUser!['nationalId'] ?? '-'}"),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () {
                                // تأكيد الحذف عبر حوار بسيط قبل التنفيذ
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("تأكيد حذف"),
                                    content: const Text(
                                        "هل أنت متأكد أنك تريد حذف هذا المستخدم؟"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("إلغاء"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx); // اغلق الحوار
                                          _deleteFoundUser();
                                        },
                                        child: const Text(
                                          "حذف",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: const Text(
                                "حذف المستخدم",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // مسافة سفلية مرنة
              const SizedBox(height: 16),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
