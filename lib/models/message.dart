import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, location }

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map, String id) {
    try {
      return Message(
        id: id,
        conversationId: map['conversationId'] ?? '',
        senderId: map['senderId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        type: _parseMessageType(map['type'] ?? 'text'),
        content: map['content'] ?? '',
        timestamp: _parseTimestamp(map['timestamp']),
        isRead: map['isRead'] ?? false,
      );
    } catch (e) {
      print('❌ Error converting message: $e');
      return Message(
        id: id,
        conversationId: map['conversationId'] ?? '',
        senderId: map['senderId'] ?? '',
        receiverId: map['receiverId'] ?? '',
        type: MessageType.text,
        content: 'Error: Could not load message content.',
        timestamp: DateTime.now(),
      );
    }
  }

  static MessageType _parseMessageType(String type) {
    switch (type) {
      case 'image':
        return MessageType.image;
      case 'location':
        return MessageType.location;
      default:
        return MessageType.text;
    }
  }

  static DateTime _parseTimestamp(dynamic ts) {
    try {
      if (ts == null) return DateTime.now();
      if (ts is Timestamp) return ts.toDate();
      if (ts is DateTime) return ts;
      if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
      if (ts is String) return DateTime.parse(ts);
    } catch (e) {
      print('Failed to parse timestamp: $e');
    }
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'type': type.toString().split('.').last,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}
