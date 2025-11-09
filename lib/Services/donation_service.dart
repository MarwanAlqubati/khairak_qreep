import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exakhairak_qreep/models/app_Donation.dart';

class DonationService {
  static final CollectionReference<Map<String, dynamic>> _donations =
      FirebaseFirestore.instance.collection('donations');

  /// توليد رقم طلب فريد تصاعدي
  static Future<String> generateUniqueDonationId() async {
    try {
      final snapshot = await _donations
          .orderBy('donorNumber', descending: true)
          .limit(1)
          .get();

      // إذا لم توجد طلبات، يبدأ من 1
      int nextId = 1;
      if (snapshot.docs.isNotEmpty) {
        // الحصول على أعلى donorNumber الحالي
        final highestDonationId =
            int.tryParse(snapshot.docs.first.data()['donorNumber'] ?? '0') ?? 0;
        nextId = highestDonationId + 1; // زيادة 1 للحصول على الرقم التالي
      }

      return nextId
          .toString()
          .padLeft(6, '0'); // تحويل الرقم إلى سلسلة مع إضافة أصفار على اليسار
    } catch (e) {
      print("Error generating unique reqid: $e");
      return '000001'; // القيمة الافتراضية في حالة الخطأ
    }
  }

  static Future<void> addDonation(AppDonation donation) async {
    try {
      await _donations.add(donation.toMap());
      print("Donation added successfully.");
    } catch (e) {
      print("Error adding donation: $e");
    }
  }
}
