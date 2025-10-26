import 'dart:io';

import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:exakhairak_qreep/models/message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  void _sendTextMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    ChatService.sendTextMessage(
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      receiverId: widget.otherUser.uid,
      text: text,
    );

    _messageController.clear();
    _scrollToBottom();
  }

  void _sendImageMessage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      ChatService.sendImageMessage(
        conversationId: widget.conversationId,
        senderId: widget.currentUserId,
        receiverId: widget.otherUser.uid,
        imageFile: File(image.path),
      );
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
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('حدث خطأ في تحميل الرسائل'));
                }

                final messages = snapshot.data ?? [];

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

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
            Image.network(message.content,
                width: 200, height: 150, fit: BoxFit.cover),
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
