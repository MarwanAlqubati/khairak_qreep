// lib/models/app_Charity.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AppCharity {
  final String? uid;
  final String titlle;
  final String charityname;
  final String description;
  final String datecharity;
  final String satats;
  final String iconName; // الحقل الجديد

  AppCharity({
    this.uid,
    required this.titlle,
    required this.charityname,
    required this.description,
    required this.datecharity,
    this.satats = '0',
    this.iconName = 'volunteer_activism', // قيمة افتراضية
  });

  Map<String, dynamic> toMap() {
    return {
      'titlle': titlle,
      'charityname': charityname,
      'description': description,
      'datecharity': datecharity,
      'satats': satats,
      'icon': iconName, // نحفظ الاسم هنا تحت المفتاح 'icon'
    };
  }

  factory AppCharity.fromMap(String uid, Map<String, dynamic> map) {
    return AppCharity(
      uid: uid,
      titlle: map['titlle'] ?? '',
      charityname: map['charityname'] ?? '',
      description: map['description'] ?? '',
      datecharity: map['datecharity'] ?? '',
      satats: map['satats'] ?? '0',
      iconName: map['icon'] ?? 'volunteer_activism',
    );
  }

  factory AppCharity.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppCharity.fromMap(doc.id, data);
  }

  @override
  String toString() {
    return 'AppCharity(titlle: $titlle, charityname: $charityname, datecharity: $datecharity, description: $description, icon: $iconName)';
  }
}
