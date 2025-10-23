import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';

import 'package:flutter/material.dart';

import 'users_management.dart';

class DeleteUserPage extends StatefulWidget {
  @override
  _DeleteUserPageState createState() => _DeleteUserPageState();
}

class _DeleteUserPageState extends State<DeleteUserPage> {
  final TextEditingController idSearchController = TextEditingController();
  bool _isLoading = false;
  AppUser? foundUser;
  String infoMessage = "";

  /// البحث عن المستخدم برقم الهوية
  Future<void> _searchById() async {
    final query = idSearchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        foundUser = null;
        infoMessage = "أدخل رقم الهوية للبحث";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      foundUser = null;
      infoMessage = "";
    });

    try {
      final user = await AuthService.searchUserByNationalId(query);
      print(user);
      if (user != null) {
        setState(() {
          foundUser = user;
          infoMessage = "";
        });
      } else {
        setState(() {
          foundUser = null;
          infoMessage = "لم يتم العثور على مستخدم برقم الهوية هذا";
        });
      }
    } catch (e) {
      setState(() {
        infoMessage = "حدث خطأ أثناء البحث: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// حذف المستخدم من Firestore
  Future<void> _deleteUser() async {
    if (foundUser == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل أنت متأكد أنك تريد حذف هذا المستخدم؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "حذف",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await AuthService.deleteUser(foundUser!.uid);
      setState(() {
        foundUser = null;
        idSearchController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("تم حذف المستخدم ${foundUser?.name ?? ''} بنجاح")),
      );

      // الرجوع للصفحة السابقة بعد الحذف
      await Future.delayed(const Duration(milliseconds: 700));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserManagementPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("فشل الحذف: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Icon(Icons.volunteer_activism,
                        color: Colors.amber, size: 60),
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

              // حقل البحث
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
                        label: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("بحث"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isLoading ? null : _searchById,
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
                                  foundUser!.name,
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
                          Text("الإيميل: ${foundUser!.email}"),
                          const SizedBox(height: 4),
                          Text("العنوان : ${foundUser!.address}"),
                          const SizedBox(height: 4),
                          Text("رقم الهوية: ${foundUser!.nationalId}"),
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
                              onPressed: _isLoading ? null : _deleteUser,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text(
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
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
