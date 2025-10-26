import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/conversation.dart';
import '../models/message.dart';
import '../models/app_user.dart';

class ChatService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // إنشاء أو الحصول على محادثة موجودة
  static Future<String> getOrCreateConversation(
      String user1Id, String user2Id) async {
    final conversationsRef = _firestore.collection('conversations');

    // البحث عن محادثة موجودة
    final existingConversation = await conversationsRef
        .where('participants', arrayContains: user1Id)
        .get()
        .then((snapshot) => snapshot.docs.firstWhere(
              (doc) => List<String>.from(doc['participants']).contains(user2Id),
              // orElse: () => null,
            ));

    if (existingConversation != null) {
      return existingConversation.id;
    }

    // إنشاء محادثة جديدة
    final newConversationRef = conversationsRef.doc();
    final conversation = Conversation(
      id: newConversationRef.id,
      participants: [user1Id, user2Id],
      lastMessage: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await newConversationRef.set(conversation.toMap());
    return newConversationRef.id;
  }

  // إرسال رسالة نصية
  static Future<void> sendTextMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    await _sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.text,
      content: text,
    );
  }

  // إرسال صورة
  static Future<void> sendImageMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required File imageFile,
  }) async {
    try {
      // رفع الصورة إلى Firebase Storage
      final fileName =
          'chat_images/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = _storage.ref().child(fileName);
      final uploadTask = await storageRef.putFile(imageFile);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      await _sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        type: MessageType.image,
        content: imageUrl,
      );
    } catch (e) {
      print('Error uploading image: $e');
      throw e;
    }
  }

  // إرسال موقع
  static Future<void> sendLocationMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required double latitude,
    required double longitude,
  }) async {
    final locationData = {
      'latitude': latitude,
      'longitude': longitude,
      'address': 'الموقع الجغرافي', // يمكنك إضافة reverse geocoding هنا
    };

    await _sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      type: MessageType.location,
      content: locationData.toString(),
    );
  }

  // دالة مساعدة لإرسال الرسائل
  static Future<void> _sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required MessageType type,
    required String content,
  }) async {
    final messagesRef = _firestore.collection('messages');
    final conversationsRef = _firestore.collection('conversations');

    // إضافة الرسالة
    final messageRef = messagesRef.doc();
    final message = Message(
      id: messageRef.id,
      conversationId: conversationId,
      senderId: senderId,
      receiverId: receiverId,
      type: type,
      content: content,
      timestamp: DateTime.now(),
    );

    await messageRef.set(message.toMap());

    // تحديث آخر رسالة في المحادثة
    final lastMessage = {
      'content': type == MessageType.text ? content : _getMessagePreview(type),
      'senderId': senderId,
      'timestamp': Timestamp.now(),
      'type': type.toString().split('.').last,
    };

    await conversationsRef.doc(conversationId).update({
      'lastMessage': lastMessage,
      'updatedAt': Timestamp.now(),
    });
  }

  static String _getMessagePreview(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷 صورة';
      case MessageType.location:
        return '📍 موقع';
      default:
        return '';
    }
  }

  // الحصول على جميع المحادثات للمستخدم
  static Stream<List<Conversation>> getUserConversations(String userId) {
    return _firestore
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final validConversations = <Conversation>[];

      for (final doc in snapshot.docs) {
        try {
          // التحقق من صحة البيانات قبل التحويل
          final data = doc.data();

          if (_isValidConversationData(data)) {
            final conversation = Conversation.fromMap(data, doc.id);
            validConversations.add(conversation);
          } else {
            print('⚠️ مستند محادثة غير صالح: ${doc.id}');
            print('البيانات: $data');
          }
        } catch (e) {
          print('❌ خطأ في تحويل المحادثة ${doc.id}: $e');
        }
      }

      return validConversations;
    });
  }

  static bool _isValidConversationData(Map<String, dynamic> data) {
    // التحقق من وجود الحقول الأساسية
    if (data['participants'] == null) return false;
    if (data['updatedAt'] == null) return false;
    if (data['createdAt'] == null) return false;

    // التحقق من أن participants مصفوفة
    if (data['participants'] is! List) return false;

    // التحقق من أن جميع عناصر المصفوفة نصوص
    final participants = data['participants'] as List;
    for (final participant in participants) {
      if (participant is! String) return false;
    }

    return true;
  }

  // الحصول على رسائل المحادثة
  static Stream<List<Message>> getConversationMessages(String conversationId) {
    return _firestore
        .collection('messages')
        .where('conversationId', isEqualTo: conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.data(), doc.id))
            .toList());
  }

  // الحصول على بيانات المستخدم الآخر في المحادثة
  static Future<AppUser?> getOtherParticipant(
      Conversation conversation, String currentUserId) async {
    final otherUserId =
        conversation.participants.firstWhere((id) => id != currentUserId);

    final userDoc = await _firestore.collection('users').doc(otherUserId).get();

    if (userDoc.exists) {
      return AppUser.fromDocument(
          userDoc as DocumentSnapshot<Map<String, dynamic>>);
    }

    return null;
  }
}
