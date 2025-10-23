// lib/Services/charity_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:exakhairak_qreep/models/app_Charity.dart';

class CharityService {
  static final CollectionReference<Map<String, dynamic>> _charity =
      FirebaseFirestore.instance.collection('charity');

  /// إضافة حملة (يخزن الحقل 'icon' كما في toMap)
  static Future<void> addCampaign(AppCharity charity) async {
    try {
      await _charity.add(charity.toMap());
      debugPrint("Campaign added successfully.");
    } catch (e, st) {
      debugPrint("Error adding campaign: $e");
      debugPrint(st.toString());
      rethrow;
    }
  }

  /// جلب العناصر النشطة (satats == '1')
  static Future<List<AppCharity>> getStatsActive() async {
    try {
      final snapshot = await _charity.where('satats', isEqualTo: '1').get();
      final appCharity =
          snapshot.docs.map((doc) => AppCharity.fromDocument(doc)).toList();
      debugPrint("Fetched ${appCharity.length} active charities.");
      return appCharity;
    } catch (e, st) {
      debugPrint("Error fetching active charities: $e");
      debugPrint(st.toString());
      return <AppCharity>[];
    }
  }

  /// يضيف قائمة حملات افتراضية إلى مجموعة 'charity' في Firestore.
  /// - skipIfExists = true : يتخطى الحملات التي يوجد لها مستند بنفس الحقل 'titlle'
  static Future<void> seedDefaultCampaigns({bool skipIfExists = true}) async {
    final List<Map<String, String>> campaigns = [
      {
        "titlle": "حملة العودة للمدارس",
        "icon": "school", // سنخزن اسم الأيقونة كسلسلة
        "description": "جمع أدوات مدرسية للطلاب المحتاجين.",
        "charityname": "جمعية البر الخيرية",
        "datecharity": "من 10 إلى 25 أغسطس"
      },
      {
        "titlle": "حملة دفء الشتاء",
        "icon": "ac_unit",
        "description": "توزيع بطانيات وملابس شتوية.",
        "charityname": "جمعية الإحسان",
        "datecharity": "من 1 إلى 20 ديسمبر"
      },
      {
        "titlle": "حملة إفطار صائم",
        "icon": "fastfood",
        "description": "توزيع وجبات إفطار للصائمين في رمضان.",
        "charityname": "جمعية الإكرام",
        "datecharity": "شهر رمضان المبارك"
      },
    ];

    try {
      for (final c in campaigns) {
        final title = c['titlle'] ?? '';
        if (title.isEmpty) continue;

        if (skipIfExists) {
          final q =
              await _charity.where('titlle', isEqualTo: title).limit(1).get();
          if (q.docs.isNotEmpty) {
            debugPrint("Skipping existing campaign: $title");
            continue;
          }
        }

        final appCharity = AppCharity(
          titlle: title,
          charityname: c['charityname'] ?? '',
          description: c['description'] ?? '',
          datecharity: c['datecharity'] ?? '',
          satats: '1', // اجعلها نشطة افتراضياً
          iconName: c['icon'] ?? 'volunteer_activism',
        );

        await _charity.add(appCharity.toMap());
        debugPrint("Added campaign: $title");
      }

      debugPrint("Seeding default campaigns completed.");
    } catch (e, st) {
      debugPrint("Error seeding campaigns: $e");
      debugPrint(st.toString());
      rethrow;
    }
  }

  /// ----- دالة ترحيل: تضيف الحقل 'icon' بقيمة افتراضية لكل المستندات التي لا تملك الحقل -----
  /// defaultIconName: مثل 'ac_unit' أو 'volunteer_activism'
  /// قومي بتشغيل هذه الدالة مرة واحدة (مثلاً عبر زر مؤقت أثناء التطوير)، ثم أزِلي الزر.
  static Future<void> addIconFieldToAllDocs(String defaultIconName) async {
    try {
      final snapshot = await _charity.get();
      if (snapshot.docs.isEmpty) {
        debugPrint("No documents to migrate.");
        return;
      }

      WriteBatch batch = FirebaseFirestore.instance.batch();
      int counter = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        // إذا الحقل موجود وتابع له قيمة فلا تُحدّث
        if (data.containsKey('icon') && data['icon'] != null) {
          continue;
        }

        final docRef = _charity.doc(doc.id);
        batch.update(docRef, {'icon': defaultIconName});
        counter++;

        // Firestore batches محدودة إلى 500 عملية، فنعمل commit كل 400 لتجنب المشاكل
        if (counter % 400 == 0) {
          await batch.commit();
          batch = FirebaseFirestore.instance.batch();
        }
      }

      // commit الباقي
      await batch.commit();
      debugPrint(
          "Migration complete: set icon='$defaultIconName' on missing docs.");
    } catch (e, st) {
      debugPrint("Error during migration: $e");
      debugPrint(st.toString());
      rethrow;
    }
  }

  // باقي الدوال كما تريد...
}

//   // باقي الدوال كما تريد...
//   // import 'package:flutter/material.dart';

//   IconData iconDataFromName(String name) {
//     const iconMap = {
//       'school': Icons.school,
//       'ac_unit': Icons.ac_unit,
//       'fastfood': Icons.fastfood,
//       'checkroom': Icons.checkroom,
//       'food_bank': Icons.food_bank,
//       'volunteer_activism': Icons.volunteer_activism,
//       // أضف أسماء أيقونات تحتاجها...
//     };

//     return iconMap[name] ?? Icons.volunteer_activism;
//   }
// }
