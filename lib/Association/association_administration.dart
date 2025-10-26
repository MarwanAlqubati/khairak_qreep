import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/Services/charity_service.dart';
import 'package:exakhairak_qreep/models/app_Charity.dart';

class ManageCampaignsPage extends StatefulWidget {
  const ManageCampaignsPage({super.key});

  @override
  State<ManageCampaignsPage> createState() => _ManageCampaignsPageState();
}

class _ManageCampaignsPageState extends State<ManageCampaignsPage> {
  late Future<List<AppCharity>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  void _loadCampaigns() {
    final currentUser = AuthService.currentUser();
    final userid = currentUser?.uid;
    if (userid == null) {
      // إذا المستخدم غير مسجل، اجعل المستقبل يعيد قائمة فارغة
      _campaignsFuture = Future.value(<AppCharity>[]);
    } else {
      // لا نستخدم await هنا؛ نُعيّن Future مباشرة
      _campaignsFuture = CharityService.getAllUser(userid);
    }
    // حدث الواجهة ليستخدم Future الجديد
    setState(() {});
  }

  IconData _iconFromName(String name) {
    const iconMap = {
      'school': Icons.school,
      'ac_unit': Icons.ac_unit,
      'fastfood': Icons.fastfood,
      'family_restroom': Icons.family_restroom,
      'volunteer_activism': Icons.volunteer_activism,
      'local_hospital': Icons.local_hospital,
      'handshake': Icons.handshake,
      'favorite': Icons.favorite,
      'campaign': Icons.campaign,
    };
    return iconMap[name] ?? Icons.campaign;
  }

  Future<void> _toggleStatus(AppCharity charity) async {
    if (charity.uid == null || charity.uid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن تحديث الحملة: معرف المستند غير متوفر')),
      );
      return;
    }

    final newStatus = charity.satats == '1' ? '0' : '1';

    try {
      await FirebaseFirestore.instance
          .collection('charity')
          .doc(charity.uid)
          .update({'satats': newStatus});
      // حدّث القيمة محليًا ثم أعد تحميل القائمة
      // charity.satats = newStatus;
      setState(() {}); // لتحديث الواجهة السريعة
      // إعادة تحميل من السيرفر للتأكد من التزامن
      _loadCampaigns();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الحملة بنجاح')),
      );
    } catch (e) {
      debugPrint('Error toggling status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء تحديث الحالة: $e')),
      );
    }
  }

  Future<void> _deleteCampaign(AppCharity charity) async {
    if (charity.uid == null || charity.uid!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('لا يمكن حذف الحملة: معرف المستند غير متوفر')),
      );
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل تريد حذف "${charity.titlle}"؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('إلغاء')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('حذف')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('charity')
          .doc(charity.uid)
          .delete();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('تم حذف الحملة')));
      _loadCampaigns();
    } catch (e) {
      debugPrint('Error deleting campaign: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('خطأ أثناء الحذف: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              children: [
                // شريط علوي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text("رجوع",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const Text(
                      "إدارة الحملات",
                      style: TextStyle(
                          color: Colors.teal,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: FutureBuilder<List<AppCharity>>(
                    future: _campaignsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text(
                                "خطأ في تحميل الحملات: ${snapshot.error}"));
                      }
                      final campaigns = snapshot.data ?? [];
                      if (campaigns.isEmpty) {
                        return const Center(
                            child: Text("لا توجد حملات حالياً."));
                      }

                      return ListView.builder(
                        itemCount: campaigns.length,
                        itemBuilder: (context, i) {
                          final c = campaigns[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Icon(_iconFromName(c.iconName),
                                        color: Colors.teal.shade700),
                                    title: Text(c.titlle ?? 'بدون عنوان',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    subtitle: Text(c.datecharity ?? ''),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.blue),
                                          onPressed: () {
                                            // يمكنك فتح صفحة تعديل هنا وتمرير AppCharity
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () => _deleteCampaign(c),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if ((c.description ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 4),
                                      child: Text(c.description ?? ''),
                                    ),
                                  if ((c.charityname ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2),
                                      child: Text("الجمعية: ${c.charityname}",
                                          style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.grey)),
                                    ),
                                  Row(
                                    children: [
                                      const Text("الحالة: "),
                                      Switch(
                                        value: c.satats == '1',
                                        onChanged: (val) async {
                                          await _toggleStatus(c);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
