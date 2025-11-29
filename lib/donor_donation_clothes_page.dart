// lib/pages/donor_donation_clothes_page.dart
import 'package:exakhairak_qreep/Services/chat_service.dart';
import 'package:exakhairak_qreep/widgets/donation_shared.dart';
import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:exakhairak_qreep/Services/donation_service.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';
import 'package:exakhairak_qreep/models/app_Donation.dart';

class DonorDonationClothesPage extends StatefulWidget {
  const DonorDonationClothesPage({super.key});

  @override
  State<DonorDonationClothesPage> createState() =>
      _DonorDonationClothesPageState();
}

class _DonorDonationClothesPageState extends State<DonorDonationClothesPage> {
  final String category = 'الملابس';
  AppRequest? selectedRequest;
  List<AppRequest> _availableRequests = [];
  bool _loadingRequests = false;
  bool _processingDonation = false;

  // حقول إدخال التبرع
  final TextEditingController _quantityCtrl = TextEditingController();
  final TextEditingController _noteCtrl = TextEditingController();
  String _clothesType = 'عام'; // خيارات: عام, رجالي, نسائي, أطفال

  @override
  void initState() {
    super.initState();
    _loadRequestsForCategory();
  }

  Future<void> _loadRequestsForCategory() async {
    setState(() {
      _loadingRequests = true;
      _availableRequests = [];
      selectedRequest = null;
    });

    try {
      final results = await RequestsService.getRequestsNotAccepted(category);
      if (mounted) setState(() => _availableRequests = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء جلب الطلبات')));
      }
    } finally {
      if (mounted) setState(() => _loadingRequests = false);
    }
  }

  Future<void> _performClothesDonation(
      AppRequest req, int quantity, String type, String note) async {
    final user = AuthService.currentUser();
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('يجب تسجيل الدخول لإتمام التبرع.'),
          backgroundColor: Colors.red));
      return;
    }

    setState(() => _processingDonation = true);

    try {
      final donationNumber = await DonationService.generateUniqueDonationId();

      final description = 'تبرع بالملابس - نوع: $type - كمية: $quantity' +
          (note.isNotEmpty ? '\nملاحظة: $note' : '');

      final donation = AppDonation(
        donorId: user.uid,
        donorNumber: donationNumber,
        requestId: req.reqid,
        description: description,
        satats: '1',
      );

      await DonationService.addDonation(donation);
      await RequestsService.assignDonorToRequest(req.reqid, user.uid, '1');
      // إنشاء أو الحصول على المحادثة
      await ChatService.getOrCreateConversation(
        user.uid,
        req.needid,
      );

      if (!mounted) return;

      await showDonationReceiptBottomSheet(
        context: context,
        donationNumber: donationNumber,
        req: req,
        description: note,
        amount: null,
        onDone: () {
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('شكراً لتبرعك 💚')));
            _loadRequestsForCategory();
            _quantityCtrl.clear();
            _noteCtrl.clear();
            setState(() => _clothesType = 'عام');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('فشل إجراء التبرع. حاول مرة أخرى.'),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _processingDonation = false);
    }
  }

  void _showConfirmAndDonate(AppRequest req) {
    final qtyText = _quantityCtrl.text.trim();
    final quantity = int.tryParse(qtyText) ?? 0;
    final note = _noteCtrl.text.trim();

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('أدخل كمية صحيحة أكبر من صفر'),
          backgroundColor: Colors.orange));
      return;
    }

    showConfirmDialog(
      context: context,
      title: 'تأكيد التبرع بالملابس',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
              'هل تريد التبرع بكمية $quantity (${_clothesType}) للطلب رقم ${req.reqid}?'),
          const SizedBox(height: 8),
          if (note.isNotEmpty) Text('ملاحظة: $note'),
        ],
      ),
      onConfirm: () =>
          _performClothesDonation(req, quantity, _clothesType, note),
      confirmText: 'تأكيد التبرع',
    );
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donorEmail = AuthService.currentUser()?.email ?? 'ضيف';

    return Scaffold(
      appBar: AppBar(
        title: const Text('تبرعك بالملابس'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffe9fdfb), Colors.white])),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  donorHeaderCard(
                      donorEmail: donorEmail,
                      onRefresh: _loadRequestsForCategory),
                  const SizedBox(height: 14),
                  Text('الطلبات المتاحة لفئة الملابس',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800)),
                  const SizedBox(height: 8),
                  if (_loadingRequests)
                    const Center(child: CircularProgressIndicator())
                  else
                    Expanded(
                      child: requestListView(
                        requests: _availableRequests,
                        selectedReqId: selectedRequest?.reqid,
                        onSelect: (r) => setState(() => selectedRequest = r),
                      ),
                    ),
                  if (selectedRequest != null) ...[
                    const SizedBox(height: 12),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(children: [
                                Icon(Icons.checkroom,
                                    color: Colors.teal.shade700),
                                const SizedBox(width: 8),
                                Text('تفاصيل الطلب',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade700))
                              ]),
                              const SizedBox(height: 8),
                              Text(selectedRequest!.description ?? '-',
                                  style: const TextStyle(fontSize: 14)),
                              const SizedBox(height: 8),
                              Text('رقم الطلب: ${selectedRequest!.reqid}'),
                              const SizedBox(height: 12),
                              // اختيار نوع الملابس
                              DropdownButtonFormField<String>(
                                value: _clothesType,
                                items: ['عام', 'رجالي', 'نسائي', 'أطفال']
                                    .map((e) => DropdownMenuItem(
                                          value: e,
                                          child: Text(e),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null)
                                    setState(() => _clothesType = v);
                                },
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.category),
                                  labelText: 'نوع الملابس',
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                  controller: _quantityCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      prefixIcon:
                                          Icon(Icons.format_list_numbered),
                                      labelText: 'الكمية (قطع / طقم / عبوات)')),
                              const SizedBox(height: 8),
                              TextFormField(
                                  controller: _noteCtrl,
                                  minLines: 1,
                                  maxLines: 3,
                                  decoration: const InputDecoration(
                                      labelText: 'ملاحظة (اختياري)')),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: _processingDonation
                                      ? null
                                      : () => _showConfirmAndDonate(
                                          selectedRequest!),
                                  icon: _processingDonation
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white))
                                      : const Icon(Icons.volunteer_activism),
                                  label: Text(_processingDonation
                                      ? 'جارٍ تنفيذ التبرع...'
                                      : 'تبرع الآن'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal),
                                ),
                              ),
                            ]),
                      ),
                    ),
                  ],
                ]),
          ),
        ),
      ),
    );
  }
}
