// lib/models/campaign_registration.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class CampaignRegistration {
  final String? id;
  final String campaignId;
  final String campaignTitle;
  final String userId;
  final String userName;
  final Timestamp registeredAt;

  CampaignRegistration({
    this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.userId,
    required this.userName,
    Timestamp? registeredAt,
  }) : registeredAt = registeredAt ?? Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'campaignId': campaignId,
      'campaignTitle': campaignTitle,
      'userId': userId,
      'userName': userName,
      'registeredAt': registeredAt,
    };
  }

  factory CampaignRegistration.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CampaignRegistration(
      id: doc.id,
      campaignId: data['campaignId'] ?? '',
      campaignTitle: data['campaignTitle'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      registeredAt: data['registeredAt'] ?? Timestamp.now(),
    );
  }
}
