import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  final List<String> participants;
  final Map<String, dynamic> lastMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Conversation({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map, String id) {
    try {
      // معالجة participants
      List<String> participants = [];
      if (map['participants'] is List) {
        participants = List<String>.from(
            (map['participants'] as List).where((item) => item is String));
      }

      // معالجة التواريخ
      DateTime createdAt;
      DateTime updatedAt;

      if (map['createdAt'] is Timestamp) {
        createdAt = (map['createdAt'] as Timestamp).toDate();
      } else {
        createdAt = DateTime.now();
      }

      if (map['updatedAt'] is Timestamp) {
        updatedAt = (map['updatedAt'] as Timestamp).toDate();
      } else {
        updatedAt = DateTime.now();
      }

      // معالجة lastMessage
      Map<String, dynamic> lastMessage = {};
      if (map['lastMessage'] is Map) {
        lastMessage = Map<String, dynamic>.from(map['lastMessage'] as Map);
      }

      return Conversation(
        id: id,
        participants: participants,
        lastMessage: lastMessage,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    } catch (e) {
      print('❌ خطأ في تحويل المحادثة: $e');
      // إرجاع محادثة افتراضية في حالة الخطأ
      return Conversation(
        id: id,
        participants: [],
        lastMessage: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'lastMessage': lastMessage,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
