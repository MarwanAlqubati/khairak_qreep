import 'dart:io';

import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:exakhairak_qreep/models/message.dart';
import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;

import 'package:cached_network_image/cached_network_image.dart';

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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // يمكنك اظهار رسالة تطلب تفعيل خدمات الموقع
      throw Exception('خدمة الموقع غير مفعّلة. الرجاء تفعيل GPS.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('تم رفض صلاحية الموقع.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'صلاحية الموقع مرفوضة نهائياً. الرجاء السماح من إعدادات الجهاز.');
    }

    // الآن نأخذ الموقع الحالي
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  void _sendImageMessage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;

    try {
      if (kIsWeb) {
        // WEB: اقرأ bytes، حدّد اسم ملف مناسب، و ارفع بوظيفة الويب
        final bytes = await picked.readAsBytes();
        final ext = p.extension(picked.name).isNotEmpty
            ? p.extension(picked.name)
            : '.jpg';
        final fileName =
            'chat_images/${DateTime.now().millisecondsSinceEpoch}$ext';

        await ChatService.sendImageMessageWeb(
          conversationId: widget.conversationId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUser.uid,
          imageBytes: bytes,
          fileName: fileName,
          // contentType: 'image/png', // اختياري: إذا تبي إجبار نوع معين
        );
      } else {
        // MOBILE: استخدم File ورفع عبر putFile
        final file = File(picked.path);
        final ext = p.extension(file.path);
        final fileName =
            'chat_images/${DateTime.now().millisecondsSinceEpoch}$ext';

        await ChatService.sendImageMessage(
          conversationId: widget.conversationId,
          senderId: widget.currentUserId,
          receiverId: widget.otherUser.uid,
          imageFile: file,
          fileName: fileName,
          // contentType: 'image/jpeg', // اختياري
        );
      }
    } catch (e, st) {
      debugPrint('❌ Image upload failed: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل رفع الصورة: ${e.toString()}')),
        );
      }
    }
  }

  void _sendLocationMessage() async {
    // إنشاء رسالة مؤقتة للعرض الفوري
    final tempMessage = Message(
      id: 'temp_loc_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: widget.conversationId,
      senderId: widget.currentUserId,
      receiverId: widget.otherUser.uid,
      type: MessageType.location,
      content: 'جارٍ مشاركة الموقع...', // مؤقت
      timestamp: DateTime.now(),
      latitude: null,
      longitude: null,
    );

    setState(() {
      _localMessages.add(tempMessage);
    });
    _scrollToBottom();

    try {
      final pos = await _determinePosition();

      // تحديث الرسالة المؤقتة محليًا (اختياري)
      setState(() {
        final idx = _localMessages.indexWhere((m) => m.id == tempMessage.id);
        if (idx != -1) {
          _localMessages[idx] = Message(
            id: tempMessage.id,
            conversationId: tempMessage.conversationId,
            senderId: tempMessage.senderId,
            receiverId: tempMessage.receiverId,
            type: MessageType.location,
            content: '${pos.latitude},${pos.longitude}',
            timestamp: DateTime.now(),
            latitude: pos.latitude,
            longitude: pos.longitude,
          );
        }
      });
      _scrollToBottom();

      // أرسل للمخدم — تأكّد أن ChatService.sendLocationMessage يقبل lat/lng
      await ChatService.sendLocationMessage(
        conversationId: widget.conversationId,
        senderId: widget.currentUserId,
        receiverId: widget.otherUser.uid,
        latitude: pos.latitude,
        longitude: pos.longitude,
      );

      // بعد نجاح الإرسال قد تعتمد على Stream لتحديث الرسائل الحقيقية (فيمكان حذف temp msg إن احتجت)
    } catch (e) {
      // إزالة الـ temp message أو تحديثه لإظهار فشل
      setState(() {
        final idx = _localMessages.indexWhere((m) => m.id == tempMessage.id);
        if (idx != -1) {
          _localMessages[idx] = Message(
            id: tempMessage.id,
            conversationId: tempMessage.conversationId,
            senderId: tempMessage.senderId,
            receiverId: tempMessage.receiverId,
            type: MessageType.text,
            content: 'فشل مشاركة الموقع: ${e.toString()}',
            timestamp: DateTime.now(),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل الحصول على الموقع: ${e.toString()}')),
      );
    }
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
        child: _buildMessageContent(context),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        final imageUrl = message.content; // full image URL
        // final thumbUrl = message.thumbnailUrl; // قد تكون null
        return InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) {
              return Scaffold(
                appBar: AppBar(backgroundColor: Colors.black),
                body: Center(
                  child: Hero(
                    tag: message.id,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      progressIndicatorBuilder: (c, url, progress) =>
                          CircularProgressIndicator(value: progress.progress),
                      errorWidget: (c, url, err) => Icon(Icons.broken_image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                backgroundColor: Colors.black,
              );
            }));
          },
          child: Hero(
            tag: message.id,
            child: CachedNetworkImage(
              // imageUrl: thumbUrl ?? imageUrl,
              imageUrl: imageUrl,
              placeholder: (c, url) => Container(
                width: 200,
                height: 150,
                color: Colors.grey[300],
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (c, url, err) => SizedBox(
                width: 200,
                height: 150,
                child: Center(child: Text('فشل تحميل الصورة')),
              ),
              width: 200,
              height: 150,
              fit: BoxFit.cover,
            ),
          ),
        );
      case MessageType.location:
        final lat = message.latitude;
        final lng = message.longitude;
        final label =
            lat != null && lng != null ? '$lat, $lng' : message.content;
        return InkWell(
          onTap: () async {
            if (lat != null && lng != null) {
              final googleUrl = Uri.parse(
                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
              if (await canLaunchUrl(googleUrl)) {
                await launchUrl(googleUrl);
              }
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, color: _getTextColor()),
              SizedBox(width: 6),
              Flexible(
                  child: Text('📍 موقع: $label',
                      style: TextStyle(color: _getTextColor()))),
            ],
          ),
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
