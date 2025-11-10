// lib/constants/app_icons.dart
import 'package:flutter/material.dart';

class AppIcons {
  static final List<Map<String, dynamic>> availableIcons = [
    {'name': 'school', 'icon': Icons.school, 'label': 'تعليم'},
    {'name': 'ac_unit', 'icon': Icons.ac_unit, 'label': 'تبريد'},
    {'name': 'fastfood', 'icon': Icons.fastfood, 'label': 'طعام'},
    {'name': 'family_restroom', 'icon': Icons.family_restroom, 'label': 'أسرة'},
    {
      'name': 'volunteer_activism',
      'icon': Icons.volunteer_activism,
      'label': 'تطوع'
    },
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'مستشفى'},
    {'name': 'handshake', 'icon': Icons.handshake, 'label': 'تعاون'},
    {'name': 'favorite', 'icon': Icons.favorite, 'label': 'صحة'},
    {'name': 'campaign', 'icon': Icons.campaign, 'label': 'حملة'},
  ];

  static IconData getIconFromName(String name) {
    final iconMap = availableIcons.firstWhere(
      (icon) => icon['name'] == name,
      orElse: () => availableIcons.last,
    );
    return iconMap['icon'] as IconData;
  }

  static String getNameFromIcon(IconData icon) {
    final iconMap = availableIcons.firstWhere(
      (item) => item['icon'] == icon,
      orElse: () => availableIcons.last,
    );
    return iconMap['name'] as String;
  }
}
