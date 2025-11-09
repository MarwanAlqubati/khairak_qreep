import 'package:cloud_firestore/cloud_firestore.dart';

class AppDonation {
  final String? uid;
  final String donorId;
  final String donorNumber;
  final String requestId;
  final String description;
  final String? satats;

  AppDonation({
    this.uid,
    required this.donorId,
    required this.donorNumber,
    required this.requestId,
    required this.description,
    this.satats = '1',
  });

  /// تحويل إلى Map جاهز للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'donorId': donorId,
      'donorNumber': donorNumber,
      'requestId': requestId,
      'description': description,
      'satats': satats,
    };
  }

  /// إنشاء نسخة من Map (مثلاً من get() في Firestore)
  factory AppDonation.fromMap(String uid, Map<String, dynamic> map) {
    return AppDonation(
      uid: uid,
      donorId: map['donorId'] ?? '',
      donorNumber: map['donorNumber'] ?? '',
      requestId: map['requestId'] ?? '',
      description: map['description'] ?? '',
      satats: map['satats'] ?? '1',
    );
  }

  /// إنشاء من DocumentSnapshot
  factory AppDonation.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppDonation.fromMap(doc.id, data);
  }

  /// مساعدة لطباعة معلومات للمراجعة
  @override
  String toString() {
    return 'AppDonation(donorId: $donorId, donorNumber: $donorNumber, requestId: $requestId, description: $description, satats: $satats)';
  }
}
