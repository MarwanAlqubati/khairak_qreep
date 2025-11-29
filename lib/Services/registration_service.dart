// lib/Services/registration_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:exakhairak_qreep/models/app_campaign_registration.dart';

class RegistrationService {
  static final CollectionReference<Map<String, dynamic>> _regs =
      FirebaseFirestore.instance.collection('campaign_registrations');

  /// هل المستخدم مسجل في هذه الحملة؟
  static Future<bool> isUserRegistered({
    required String campaignId,
    required String userId,
  }) async {
    try {
      final q = await _regs
          .where('campaignId', isEqualTo: campaignId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();
      return q.docs.isNotEmpty;
    } catch (e, st) {
      debugPrint('Error checking registration: $e');
      debugPrint(st.toString());
      return false;
    }
  }

  /// إضافة تسجيل (مع التحقق من التكرار داخل الدالة أيضاً)
  static Future<void> registerUser({
    required String campaignId,
    required String campaignTitle,
    required String userId,
    required String userName,
  }) async {
    try {
      final already =
          await isUserRegistered(campaignId: campaignId, userId: userId);
      if (already) {
        throw Exception('already_registered');
      }

      final reg = CampaignRegistration(
        campaignId: campaignId,
        campaignTitle: campaignTitle,
        userId: userId,
        userName: userName,
      );

      await _regs.add(reg.toMap());
      debugPrint('Registration saved for $userName -> $campaignTitle');
    } catch (e, st) {
      debugPrint('Error registering user: $e');
      debugPrint(st.toString());
      rethrow;
    }
  }

  /// جلب جميع campaignIds التي سجل فيها المستخدم (مفيدة لتحسين الواجهة)
  static Future<List<String>> getRegisteredCampaignIdsForUser(
      String userId) async {
    try {
      final q = await _regs.where('userId', isEqualTo: userId).get();
      return q.docs
          .map((d) => (d.data()['campaignId'] ?? '') as String)
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (e, st) {
      debugPrint('Error fetching user registrations: $e');
      debugPrint(st.toString());
      return <String>[];
    }
  }
}
