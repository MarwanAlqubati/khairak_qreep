import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';

import 'beneficiary_page.dart';

class TrackRequestsPage extends StatefulWidget {
  const TrackRequestsPage({super.key});

  @override
  State<TrackRequestsPage> createState() => _TrackRequestsPageState();
}

class _TrackRequestsPageState extends State<TrackRequestsPage> {
  bool _isLoading = true;
  List<RequestWithDonor> _requests = [];
  String? _errorMessage;
  // مجموعة لتتبع الطلبات التي هي قيد المعالجة الآن
  final Set<String> _processingReqIds = {};

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    try {
      final user = AuthService.currentUser();
      if (user == null) {
        setState(() {
          _errorMessage = "لم يتم العثور على المستخدم الحالي.";
          _isLoading = false;
        });
        return;
      }

      final requests = await RequestsService.getRequestsByNeedId(user.uid);
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "حدث خطأ أثناء تحميل الطلبات: $e";
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '0':
        return Colors.orange;
      case '1':
        return Colors.blue;
      case '2':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case '0':
        return 'قيد المراجعة';
      case '1':
        return 'قيد التنفيذ';
      case '2':
        return 'تم الاستلام';
      default:
        return 'غير معروف';
    }
  }

  Future<void> _changeRequestStatus(String reqid, String newStatus) async {
    setState(() => _processingReqIds.add(reqid));

    final success = await RequestsService.updateRequestStatus(reqid, newStatus);

    setState(() => _processingReqIds.remove(reqid));

    if (success) {
      // للتأكد من تزامن البيانات نعيد تحميل القائمة
      await _loadRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newStatus == '2'
              ? 'تم استلام الطلب بنجاح.'
              : 'تم تحديث: لم يتم استلام الطلب.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحديث حالة الطلب. حاول مرة أخرى.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ✅ الهيدر
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BeneficiaryPage()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text(
                        "رجوع",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 10),
                      ),
                    ),
                    const Icon(Icons.volunteer_activism,
                        size: 60, color: Colors.teal),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "متابعة الطلبات",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.teal))
                    : _errorMessage != null
                        ? Center(
                            child: Text(_errorMessage!,
                                style: const TextStyle(color: Colors.red)))
                        : _requests.isEmpty
                            ? const Center(
                                child: Text("لا توجد طلبات حتى الآن"))
                            : RefreshIndicator(
                                onRefresh: _loadRequests,
                                color: Colors.teal,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  itemCount: _requests.length,
                                  itemBuilder: (context, index) {
                                    final req = _requests[index];
                                    return _buildRequestCard(
                                        context, req, index); // مَرّر index
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(
      BuildContext context, RequestWithDonor reqWithDonor, int index) {
    final req = reqWithDonor.request;
    final donor = reqWithDonor.donor;

    final statusText = _getStatusText(req.satats);
    final statusColor = _getStatusColor(req.satats);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان و حالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(req.category,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal)),
                Text(statusText,
                    style: TextStyle(
                        fontSize: 16,
                        color: statusColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text("رقم الطلب: ${req.reqid}",
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(req.description,
                style: const TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 12),

            if (req.pay != null && req.pay!.isNotEmpty)
              Text("المبلغ: ${req.pay} ر.س",
                  style: const TextStyle(
                      fontSize: 15,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // إذا كانت الحالة 1 نعرض زرين: "لم يتم استلام" و "تم الاستلام"
            if (req.satats == '1')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _processingReqIds.contains(req.reqid)
                          ? null
                          : () => _changeRequestStatus(req.reqid, '0'),
                      icon: _processingReqIds.contains(req.reqid)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.close),
                      label: const Text("لم يتم استلام الطلب"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _processingReqIds.contains(req.reqid)
                          ? null
                          : () => _changeRequestStatus(req.reqid, '2'),
                      icon: _processingReqIds.contains(req.reqid)
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check),
                      label: const Text("تم الاستلام"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

            // لو حاب تربط زر للتواصل مع المتبرع اعرضه هنا إن وُجد donor
            // if (donor != null) ...[
            //   const SizedBox(height: 12),
            //   // مثال: زر اتصال أو رسالة (تعديله حسب بيانات donor)
            //   Text("متبرع: ${donor.name ?? '---'}",
            //       style: const TextStyle(fontSize: 14, color: Colors.black54)),
            // ],
          ],
        ),
      ),
    );
  }
}
