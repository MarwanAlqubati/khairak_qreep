// lib/pages/chat_page.dart
import 'dart:io';

import 'package:exakhairak_qreep/Services/message_service.dart';
import 'package:exakhairak_qreep/models/app_message.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId; // المستخدم الحالي
  final String targetUserId; // الى من سيتم ارسالها
  final String targetUserName; // اسمه الذي سيستقبل

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.targetUserId,
    required this.targetUserName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _isSending = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // عند دخول المحادثة، علم الرسائل السابقة كمقروءة
    MessageService.markMessagesAsRead(
      otherUserId: widget.targetUserId,
      currentUserId: widget.currentUserId,
    );
  }

  Future<void> _sendText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSending = true);
    await MessageService.sendTextMessage(
      senderId: widget.currentUserId,
      receiverId: widget.targetUserId,
      text: text,
    );
    _controller.clear();
    setState(() => _isSending = false);
    _scrollToBottom();
  }

  Future<void> _sendImage() async {
    final picked =
        await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked == null) return;
    setState(() => _isSending = true);

    final file = File(picked.path);
    try {
      await MessageService.sendImageMessage(
        senderId: widget.currentUserId,
        receiverId: widget.targetUserId,
        imageFile: file,
      );
    } catch (e) {
      debugPrint('Error sending image: $e');
      // يمكنك اظهار رسالة خطأ للمستخدم
    } finally {
      setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageTile(AppMessage msg) {
    final bool isMe = msg.senderId == widget.currentUserId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: () => _showMessageOptions(msg),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 320),
          decoration: BoxDecoration(
            color: isMe ? Colors.teal.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft:
                  isMe ? const Radius.circular(16) : const Radius.circular(0),
              bottomRight:
                  isMe ? const Radius.circular(0) : const Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (msg.imageUrl != null && msg.imageUrl!.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  height: 180,
                  width: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(msg.imageUrl!),
                    ),
                  ),
                ),
              Text(msg.text, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(msg.createdAt),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 6),
                  if (isMe)
                    Icon(
                      msg.isRead ? Icons.done_all : Icons.check,
                      size: 14,
                      color: msg.isRead ? Colors.blue : Colors.grey,
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (now.difference(dt).inDays == 0) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } else {
      return "${dt.day}/${dt.month}";
    }
  }

  void _showMessageOptions(AppMessage msg) {
    final isMine = msg.senderId == widget.currentUserId;
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            if (isMine)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('حذف الرسالة'),
                onTap: () async {
                  Navigator.pop(context);
                  await MessageService.deleteMessage(msg.id);
                },
              ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('نسخ النص'),
              onTap: () {
                Navigator.pop(context);
                // نسخ للنص
                // Clipboard.setData(ClipboardData(text: msg.text));
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('إلغاء'),
              onTap: () => Navigator.pop(context),
            ),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = MessageService.getMessagesStream(
        widget.currentUserId, widget.targetUserId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Row(children: [
          CircleAvatar(
              backgroundColor: Colors.white70,
              child: Text(widget.targetUserName[0])),
          const SizedBox(width: 10),
          Text(widget.targetUserName),
        ]),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<AppMessage>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(child: Text('ابدأ المحادثة الآن 💬'));
                }

                // بعد ظهور الرسائل: علمها كمقروءة
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  MessageService.markMessagesAsRead(
                    otherUserId: widget.targetUserId,
                    currentUserId: widget.currentUserId,
                  );
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _buildMessageTile(messages[i]),
                );
              },
            ),
          ),

          // شريط الإرسال
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: Colors.grey.shade100, boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 6,
                  offset: const Offset(0, -2))
            ]),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.image, color: Colors.teal),
                      onPressed: _sendImage),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration.collapsed(
                          hintText: 'اكتب رسالتك هنا...'),
                      onSubmitted: (_) => _sendText(),
                    ),
                  ),
                  IconButton(
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send, color: Colors.amber),
                    onPressed: _isSending ? null : _sendText,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
