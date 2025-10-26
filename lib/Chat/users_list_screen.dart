import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class UsersListScreen extends StatefulWidget {
  @override
  _UsersListScreenState createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<AppUser> _users = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await AuthService.getAllUsersExceptCurrent();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _startChat(AppUser otherUser) async {
    if (currentUser == null) return;

    try {
      // إظهار مؤشر تحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // إنشاء أو الحصول على المحادثة
      final conversationId = await ChatService.getOrCreateConversation(
        currentUser!.uid,
        otherUser.uid,
      );

      // إغلاق مؤشر التحميل والانتقال إلى الشات
      Navigator.pop(context); // إغلاق ال loading dialog
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            conversationId: conversationId,
            otherUser: otherUser,
            currentUserId: currentUser!.uid,
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // إغلاق ال loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في بدء المحادثة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('المستخدمين'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 50),
                      SizedBox(height: 10),
                      Text('حدث خطأ: $_error'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadUsers,
                        child: Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                )
              : _users.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 80, color: Colors.grey),
                          SizedBox(height: 20),
                          Text(
                            'لا يوجد مستخدمين آخرين',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _users.length,
                      itemBuilder: (context, index) {
                        final user = _users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            child: Text(user.name[0].toUpperCase()),
                          ),
                          title: Text(user.name),
                          subtitle: Text(user.email),
                          trailing: Icon(Icons.chat, color: Colors.teal),
                          onTap: () => _startChat(user),
                        );
                      },
                    ),
    );
  }
}
