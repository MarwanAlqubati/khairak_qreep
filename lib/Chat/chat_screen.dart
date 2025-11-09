import 'dart:io';

import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:exakhairak_qreep/models/message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ChatScreen extends StatefulWidget {
  final String conversationId;
  final AppUser otherUser;
  final String currentUserId;

  const ChatScreen({
    required this.conversationId,
    required this.otherUser,
    required this.currentUserId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _messageCount = 0;

  List<Message> _localMessages = []; // احتفظ برسائل مؤقتة

  void _sendTextMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // أنشئ رسالة محلية مؤقتة للعرض الفوري
    final tempMessage = Message(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      receiverId: widget.otherUser.uid,
      type: MessageType.text,
      content: text,
      timestamp: DateTime.now(),
    );

    setState(() {
      _localMessages.add(tempMessage);
      _messageController.clear();
    });
    _scrollToBottom();

    try {
      await ChatService.sendTextMessage(
        conversationId: widget.conversationId,
        senderId: widget.currentUserId,
        receiverId: widget.otherUser.uid,
        text: text,
      );
      // بعد نجاح الإرسال، يمكنك اختيار إزالة الـ temp message أو استبدالها بالنسخة الحقيقية من الـ stream
    } catch (e) {
      // فشل الإرسال: علم المستخدم أو حدّث الـ ui
      print('Send failed: $e');
    }
  }

  void _sendImageMessage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    if (kIsWeb) {
      // Web: read bytes and call a web-specific uploader
      final bytes = await image.readAsBytes();
      final contentType = 'image/png'; // or detect dynamically if needed
      try {
        await ChatService.sendImageMessageWeb(
          conversationId: widget.conversationId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUser.uid,
          imageData: bytes,
          contentType: contentType,
          fileName: 'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
      } catch (e) {
        print('Upload failed (web): $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل رفع الصورة على الويب')));
      }
    } else {
      // Mobile: convert to File and use existing method
      final file = File(image.path);
      try {
        await ChatService.sendImageMessage(
          conversationId: widget.conversationId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUser.uid,
          imageFile: file,
        );
      } catch (e) {
        print('Upload failed (mobile): $e');
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('فشل رفع الصورة')));
      }
    }
  }

  void _sendLocationMessage() {
    // يمكنك استخدام geolocator package للحصول على الموقع
    // هذا مثال بموقع افتراضي
    ChatService.sendLocationMessage(
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      receiverId: widget.otherUser.uid,
      latitude: 24.7136,
      longitude: 46.6753,
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(widget.otherUser.name[0].toUpperCase()),
            ),
            SizedBox(width: 10),
            Text(widget.otherUser.name),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream:
                  ChatService.getConversationMessages(widget.conversationId),
              initialData: const [],
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  // طباعة الخطأ الكامل في الكونسول
                  print(
                      'Stream error in conversation ${widget.conversationId}: ${snapshot.error}');
                  // اظهار رسالة للمستخدم مع نص الخطأ للdebug (يمكن ازالته لاحقًا)
                  return Center(
                      child:
                          Text('حدث خطأ في تحميل الرسائل:\n${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.length > _messageCount) {
                  _messageCount = messages.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return MessageBubble(
                      message: messages[index],
                      isMe: messages[index].senderId == widget.currentUserId,
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Row(
        children: [
          PopupMenuButton<String>(
            icon: Icon(Icons.add, color: Colors.teal),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'image',
                child: Row(
                  children: [
                    Icon(Icons.image, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('صورة'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'location',
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('موقع'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'image') {
                _sendImageMessage();
              } else if (value == 'location') {
                _sendLocationMessage();
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالة...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => _sendTextMessage(),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.teal,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendTextMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.teal : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: _buildMessageContent(),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📷 صورة', style: TextStyle(color: _getTextColor())),
            SizedBox(height: 4),
            Image.network(
              message.content,
              width: 200,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return SizedBox(
                  width: 200,
                  height: 150,
                  child: Center(
                      child: CircularProgressIndicator(
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                              : null)),
                );
              },
              errorBuilder: (c, e, s) {
                return SizedBox(
                  width: 200,
                  height: 150,
                  child: Center(child: Text('فشل تحميل الصورة')),
                );
              },
            )
          ],
        );
      case MessageType.location:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: _getTextColor()),
            SizedBox(width: 4),
            Text('📍 موقع', style: TextStyle(color: _getTextColor())),
          ],
        );
      default:
        return Text(
          message.content,
          style: TextStyle(color: _getTextColor()),
        );
    }
  }

  Color _getTextColor() {
    return isMe ? Colors.white : Colors.black;
  }
}
