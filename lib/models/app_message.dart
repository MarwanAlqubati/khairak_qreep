// lib/models/app_message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج الرسالة
class AppMessage {
  final String id; // معرف المستند في Firestore (قد يكون '' قبل الارسال)
  final String senderId;
  final String receiverId;
  final List<String> participants; // [senderId, receiverId] مُرتب أبجدياً
  final String text;
  final String? imageUrl;
  final String? fileUrl;
  final GeoPoint? location;
  final DateTime createdAt;
  final bool isRead;

  AppMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.participants,
    required this.text,
    this.imageUrl,
    this.fileUrl,
    this.location,
    required this.createdAt,
    this.isRead = false,
  });

  /// تحويل إلى Map للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'participants': participants,
      'text': text,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  /// إنشاء نموذج من Map (Firestore)
  factory AppMessage.fromMap(Map<String, dynamic> data, String docId) {
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    return AppMessage(
      id: docId,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      participants: List<String>.from(data['participants'] ?? []),
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      fileUrl: data['fileUrl'],
      location: data['location'] as GeoPoint?,
      createdAt: ts?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }
}
