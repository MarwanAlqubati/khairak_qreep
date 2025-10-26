import 'package:exakhairak_qreep/Chat/users_list_screen.dart';
import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/Services/firebase_services.dart';
import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:exakhairak_qreep/models/conversation.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'chat_screen.dart';

class ConversationsListScreen extends StatefulWidget {
  @override
  _ConversationsListScreenState createState() =>
      _ConversationsListScreenState();
}

class _ConversationsListScreenState extends State<ConversationsListScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('يجب تسجيل الدخول أولاً'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('المحادثات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: () {
              // الانتقال إلى قائمة المستخدمين لبدء محادثة جديدة
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UsersListScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Conversation>>(
        stream: ChatService.getUserConversations(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'خطأ في تحميل المحادثات',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'لا توجد محادثات بعد',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'ابدأ محادثة جديدة مع مستخدم آخر',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UsersListScreen()),
                      );
                    },
                    child: Text('بدء محادثة جديدة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return FutureBuilder<AppUser?>(
                future: ChatService.getOtherParticipant(
                    conversation, currentUser!.uid),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text('جاري التحميل...'),
                    );
                  }

                  final otherUser = userSnapshot.data;

                  return ConversationListItem(
                    conversation: conversation,
                    otherUser: otherUser,
                    currentUserId: currentUser!.uid,
                    onTap: () {
                      if (otherUser != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              conversationId: conversation.id,
                              otherUser: otherUser,
                              currentUserId: currentUser!.uid,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ConversationListItem extends StatelessWidget {
  final Conversation conversation;
  final AppUser? otherUser;
  final String currentUserId;
  final VoidCallback onTap;

  const ConversationListItem({
    required this.conversation,
    required this.otherUser,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMessage = conversation.lastMessage;
    final isCurrentUserSender = lastMessage['senderId'] == currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        child: otherUser != null
            ? Text(otherUser!.name[0].toUpperCase())
            : Icon(Icons.person),
      ),
      title: Text(
        otherUser?.name ?? 'مستخدم',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        isCurrentUserSender
            ? 'أنت: ${lastMessage['content'] ?? ''}'
            : lastMessage['content'] ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(conversation.updatedAt),
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}
