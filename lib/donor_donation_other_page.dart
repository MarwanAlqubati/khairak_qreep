// lib/pages/donor_donation_other_page.dart
import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/widgets/donation_shared.dart';
import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:exakhairak_qreep/Services/donation_service.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';
import 'package:exakhairak_qreep/models/app_Donation.dart';

class DonorDonationOtherPage extends StatefulWidget {
  const DonorDonationOtherPage({super.key});

  @override
  State<DonorDonationOtherPage> createState() => _DonorDonationOtherPageState();
}

class _DonorDonationOtherPageState extends State<DonorDonationOtherPage> {
  String? selectedCategory;
  AppRequest? selectedRequest;

  // قوائم وداتا
  final List<String> categories = ["أجهزة", "أثاث", "أدوات"];
  List<AppRequest> _availableRequests = [];

  bool _loadingRequests = false;
  bool _processingDonation = false;

  // حقل وصف التبرع (اختياري)
  final TextEditingController _donationDescCtrl = TextEditingController();

  // جلب الطلبات غير المقبولة (satats == '0') حسب الفئة
  Future<void> _loadRequestsForCategory(String category) async {
    setState(() {
      _loadingRequests = true;
      _availableRequests = [];
      selectedRequest = null;
    });

    try {
      final results = await RequestsService.getRequestsNotAccepted(category);
      setState(() {
        _availableRequests = results;
      });
    } catch (e) {
      print("Error loading requests: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء جلب الطلبات')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingRequests = false);
    }
  }

  // انشاء تبرع وربطه بالطلب
  Future<void> _performDonation(AppRequest req, String desc) async {
    final user = AuthService.currentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('يجب تسجيل الدخول لإتمام التبرع.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _processingDonation = true);

    try {
      // توليد رقم تبرع فريد
      final donationNumber = await DonationService.generateUniqueDonationId();

      final donation = AppDonation(
        donorId: user.uid,
        donorNumber: donationNumber,
        requestId: req.reqid,
        description: desc,
        satats: '1', // افتراضي: 1 = قيد التنفيذ/مقبول
      );

      // إضافة التبرع
      await DonationService.addDonation(donation);

      // ربط التبرع بالطلب (تحديث الطلب: donorid + satats)
      await RequestsService.assignDonorToRequest(req.reqid, user.uid, '1');
      // إنشاء أو الحصول على المحادثة
      await ChatService.getOrCreateConversation(
        user.uid,
        req.needid,
      );

      // عرض إيصال جميل (BottomSheet)
      if (mounted) {
        await showDonationReceiptBottomSheet(
          context: context,
          donationNumber: donationNumber,
          req: req,
          description: desc,
          amount: null,
          onDone: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('شكراً لتبرعك 💚')));
            // بعد التبرع نعيد تحميل الطلبات المتاحة للفئة
            if (selectedCategory != null)
              _loadRequestsForCategory(selectedCategory!);
          },
        );
      }
    } catch (e) {
      print("Donation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('فشل إجراء التبرع. حاول مرة أخرى.'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _processingDonation = false);
    }
  }

  @override
  void dispose() {
    _donationDescCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar جميل
      appBar: AppBar(
        title: const Text('صفحة التبرع'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xffe9fdfb), Colors.white]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // بطاقة المتبرع (إعادة استخدام الهيدر)
                donorHeaderCard(
                  donorEmail: AuthService.currentUser()?.email ?? 'ضيف',
                  onRefresh: () {
                    if (selectedCategory != null)
                      _loadRequestsForCategory(selectedCategory!);
                  },
                ),

                const SizedBox(height: 18),

                // اختيار الفئة
                Text('اختر فئة التبرع',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('اختر فئة'),
                      value: selectedCategory,
                      items: categories
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(c))))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          selectedCategory = v;
                          _availableRequests = [];
                          selectedRequest = null;
                        });
                        _loadRequestsForCategory(v);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // عرض الطلبات المتاحة
                if (_loadingRequests)
                  const Center(
                      child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator()))
                else if (selectedCategory != null && _availableRequests.isEmpty)
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('لا توجد طلبات متاحة للفئة المختارة',
                          style: TextStyle(color: Colors.grey.shade600)))
                else if (_availableRequests.isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('اختر الطلب',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800)),
                        const SizedBox(height: 8),
                        Expanded(
                          child: requestListView(
                            requests: _availableRequests,
                            selectedReqId: selectedRequest?.reqid,
                            onSelect: (r) =>
                                setState(() => selectedRequest = r),
                          ),
                        ),
                      ],
                    ),
                  ),

                // تفاصيل الطلب و زر التبرع
                if (selectedRequest != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            Icon(Icons.info_outline,
                                color: Colors.teal.shade700),
                            const SizedBox(width: 8),
                            Text('تفاصيل الطلب',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700))
                          ]),
                          const SizedBox(height: 8),
                          Text(selectedRequest!.description ?? '-',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          if (selectedRequest!.pay != null &&
                              selectedRequest!.pay!.isNotEmpty)
                            Text('المبلغ: ${selectedRequest!.pay} ر.س',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange)),
                          const SizedBox(height: 8),
                          Text('رقم الطلب: ${selectedRequest!.reqid}'),
                          const SizedBox(height: 8),
                          // حقل ملاحظة التبرع
                          TextFormField(
                            controller: _donationDescCtrl,
                            minLines: 1,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                labelText: 'إضافة ملاحظة (اختياري)'),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _processingDonation
                                  ? null
                                  : () => showConfirmDialog(
                                        context: context,
                                        title: 'تأكيد التبرع',
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                'هل تريد تأكيد التبرع لهذا الطلب؟'),
                                            const SizedBox(height: 8),
                                            Text(
                                                'الطلب: ${selectedRequest!.category} • رقم ${selectedRequest!.reqid}',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            if (selectedRequest!.pay != null &&
                                                selectedRequest!
                                                    .pay!.isNotEmpty)
                                              Text(
                                                  'المبلغ: ${selectedRequest!.pay} ر.س'),
                                            const SizedBox(height: 8),
                                            Text(
                                                'ملاحظة: ${_donationDescCtrl.text.isEmpty ? 'لا يوجد' : _donationDescCtrl.text}'),
                                          ],
                                        ),
                                        onConfirm: () => _performDonation(
                                            selectedRequest!,
                                            _donationDescCtrl.text.trim()),
                                      ),
                              icon: _processingDonation
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.volunteer_activism),
                              label: Text(_processingDonation
                                  ? 'جارٍ إجراء التبرع...'
                                  : 'تبرع الآن'),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
