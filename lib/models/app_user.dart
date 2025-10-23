import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج بيانات المستخدم المركزي (AppUser)
/// الحقول مُصمّمة لتتوافق مع ما نخزنها في Firestore في مجموعة `users`.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? dob; // تاريخ الميلاد بصيغة 'yyyy-MM-dd'
  final String? region;
  final String? address;
  final String? nationalId;
  final String role; // 'user' أو 'admin'
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.dob,
    this.region,
    this.address,
    this.nationalId,
    this.role = 'user',
    this.createdAt,
  });

  /// تحويل إلى Map جاهز للحفظ في Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'dob': dob,
      'region': region,
      'address': address,
      'national_id': nationalId,
      'role': role,
      // ملاحظة: عند حفظ createdAt يمكنك وضع FieldValue.serverTimestamp() بدلاً من قيمة DateTime محلية
      'createdAt': createdAt == null ? null : Timestamp.fromDate(createdAt!),
    };
  }

  /// إنشاء نسخة من Map (مثلاً من get() في Firestore)
  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    Timestamp? ts;
    if (map['createdAt'] is Timestamp) ts = map['createdAt'];

    return AppUser(
      uid: uid,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      dob: map['dob'] as String?,
      region: map['region'] as String?,
      address: map['address'] as String?,
      nationalId: map['national_id'] as String?,
      role: map['role'] ?? 'user',
      createdAt: ts?.toDate(),
    );
  }

  /// إنشاء من DocumentSnapshot
  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return AppUser.fromMap(doc.id, data);
  }

  /// مساعدة لطباعة معلومات للمراجعة
  @override
  String toString() {
    return 'AppUser(uid: $uid, name: $name, email: $email,  role: $role)';
  }
}
