// lib/services/message_service.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/app_message.dart';

class MessageService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final CollectionReference<Map<String, dynamic>> _messagesCol =
      _firestore.collection('messages');

  /// ==== مساعدة: توليد participants مرتبة لضمان ثبات التجميع بين طرفين ====
  static List<String> _participants(String a, String b) {
    final list = [a, b];
    list.sort();
    return list;
  }

  /// إرسال رسالة (كائن AppMessage) — تُضيف رسالة جديدة إلى collection 'messages'
  static Future<DocumentReference<Map<String, dynamic>>> sendMessage(
      AppMessage message) async {
    final docRef = await _messagesCol.add(message.toMap());
    return docRef;
  }

  /// راحة: إرسال رسالة نصية
  static Future<void> sendTextMessage({
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    final msg = AppMessage(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      participants: _participants(senderId, receiverId),
      text: text,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await sendMessage(msg);
  }

  /// رفع ملف (صورة/ملف) إلى Firebase Storage ثم إرجاع رابط التحميل
  /// pathExample: 'chat_images/{senderId}/{timestamp}.jpg'
  static Future<String> uploadFile(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() => null);
    final url = await snapshot.ref.getDownloadURL();
    return url;
  }

  /// إرسال رسالة صورة: ترفع الصورة وتخزن رابطها في الرسالة
  static Future<void> sendImageMessage({
    required String senderId,
    required String receiverId,
    required File imageFile,
  }) async {
    final path =
        'chat_images/$senderId/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final url = await uploadFile(imageFile, path);

    final msg = AppMessage(
      id: '',
      senderId: senderId,
      receiverId: receiverId,
      participants: _participants(senderId, receiverId),
      text: '[صورة]',
      imageUrl: url,
      createdAt: DateTime.now(),
      isRead: false,
    );
    await sendMessage(msg);
  }

  /// جلب Stream للرسائل بين مستخدمين (بسبب قيود Firestore، نستخدم participants array)
  /// النتائج مرتبة زمنياً تصاعدياً
  static Stream<List<AppMessage>> getMessagesStream(
      String userA, String userB) {
    final parts = _participants(userA, userB);

    return _messagesCol
        .where('participants', arrayContains: userA)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) {
      final list =
          snap.docs.map((d) => AppMessage.fromMap(d.data(), d.id)).where((m) {
        // تحويل إلى Set للمقارنة بدون اعتبار الترتيب
        final Set<String> msgParts = Set<String>.from(m.participants);
        final Set<String> wanted = Set<String>.from(parts);
        // تحقق أن لديهما نفس الطول وأن الرسالة تحتوي جميع العناصر المطلوبة
        return msgParts.length == wanted.length && msgParts.containsAll(wanted);
      }).toList();
      return list;
    });
  }

  /// تعليم الرسائل كمقروءة من طرف محدد (تغيير isRead = true)
  /// يتم تعيين الرسائل التي أرسلها otherUser إلى currentUser
  static Future<void> markMessagesAsRead({
    required String otherUserId,
    required String currentUserId,
  }) async {
    final snapshot = await _messagesCol
        .where('senderId', isEqualTo: otherUserId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    if (snapshot.docs.isNotEmpty) {
      await batch.commit();
    }
  }

  /// حذف رسالة واحدة بواسطة messageId
  static Future<void> deleteMessage(String messageId) async {
    await _messagesCol.doc(messageId).delete();
  }

  /// جلب محادثات حديثة للمستخدم: نأخذ آخر رسالة لكل طرف مقابل
  /// مخرجات: قائمة Map تحتوي keys: otherId, lastMessage, lastAt, unreadCount
  static Future<List<Map<String, dynamic>>> fetchRecentConversations(
      String userId,
      {int limit = 50}) async {
    // جلب آخر الرسائل التي تتضمن userId
    final snapshots = await _messagesCol
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final Map<String, Map<String, dynamic>> byOther = {};

    for (var doc in snapshots.docs) {
      final msg = AppMessage.fromMap(doc.data(), doc.id);
      // تحديد الطرف الآخر
      final other = msg.senderId == userId ? msg.receiverId : msg.senderId;

      if (!byOther.containsKey(other)) {
        // حساب عدد الرسائل غير المقروءة من الطرف الآخر
        // (سيحسب لاحقًا أو نحسب هنا عبر query صغير)
        byOther[other] = {
          'otherId': other,
          'lastMessage': msg.text,
          'lastAt': msg.createdAt,
          'lastDocId': msg.id,
        };
      }
    }

    // الآن نححسب unreadCount لكل other
    final results = <Map<String, dynamic>>[];
    for (final kv in byOther.entries) {
      final otherId = kv.key;
      final unreadSnapshot = await _messagesCol
          .where('senderId', isEqualTo: otherId)
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      final unreadCount = unreadSnapshot.docs.length;

      results.add({
        'otherId': otherId,
        'lastMessage': kv.value['lastMessage'],
        'lastAt': kv.value['lastAt'],
        'unreadCount': unreadCount,
      });
    }

    // رتب حسب lastAt descending
    results.sort((a, b) {
      final aDate = a['lastAt'] as DateTime;
      final bDate = b['lastAt'] as DateTime;
      return bDate.compareTo(aDate);
    });

    return results;
  }
}
