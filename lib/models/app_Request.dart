import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات المستخدم المركزي (AppUser)
/// الحقول مُصمّمة لتتوافق مع ما نخزنها في Firestore في مجموعة `users`.
class AppRequest {
  final String? uid;
  final String reqid;
  final String needid;
  final String? donorid;
  final String description;
  final String category; // تاريخ الميلاد بصيغة 'yyyy-MM-dd'
  final String? pay;
  final String satats; // 'user' أو 'admin'

  AppRequest({
    this.uid,
    required this.reqid,
    required this.needid,
    required this.description,
    required this.category,
    this.donorid,
    this.pay,
    this.satats = '0',
  });

  /// تحويل إلى Map جاهز للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'donorid': donorid,
      'reqid': reqid,
      'needid': needid,
      'description': description,
      'category': category,
      'pay': pay,
      'satats': satats,
    };
  }

  /// إنشاء نسخة من Map (مثلاً من get() في Firestore)
  factory AppRequest.fromMap(String uid, Map<String, dynamic> map) {
    return AppRequest(
      uid: uid,
      donorid: map['donorid'] ?? '',
      reqid: map['reqid'] ?? '',
      needid: map['needid'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      pay: map['pay'] ?? '',
      satats: map['satats'] ?? '0',
    );
  }

  /// إنشاء من DocumentSnapshot
  factory AppRequest.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppRequest.fromMap(doc.id, data);
  }

  /// مساعدة لطباعة معلومات للمراجعة
  @override
  String toString() {
    return 'AppRequest(reqid: $reqid, needid: $needid, description: $description,donorid: $donorid, category: $category,pay: $pay,satats: $satats)';
  }
}
