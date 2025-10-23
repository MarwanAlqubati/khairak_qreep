import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';

import 'chat_page.dart';
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
                        child: CircularProgressIndicator(color: Colors.teal),
                      )
                    : _errorMessage != null
                        ? Center(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 16),
                            ),
                          )
                        : _requests.isEmpty
                            ? const Center(
                                child: Text(
                                  "لا توجد طلبات حتى الآن",
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadRequests,
                                color: Colors.teal,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  itemCount: _requests.length,
                                  itemBuilder: (context, index) {
                                    final req = _requests[index];

                                    return _buildRequestCard(context, req);
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
      BuildContext context, RequestWithDonor reqWithDonor) {
    final req = reqWithDonor.request;
    final donor = reqWithDonor.donor;

    final statusText = _getStatusText(req.satats);
    final statusColor = _getStatusColor(req.satats);
    print(req);
    print(donor);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 عنوان الفئة و حالة الطلب
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  req.category,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // 🔹 رقم الطلب
            Text(
              "رقم الطلب: ${req.reqid}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 وصف الطلب
            Text(
              req.description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // 🔹 المبلغ إن وجد
            if (req.pay != null && req.pay!.isNotEmpty)
              Text(
                "المبلغ: ${req.pay} ر.س",
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
            const SizedBox(height: 12),

            // 🔹 زر التواصل مع المتبرع
            if (req.satats == '1' && donor != null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          currentUserId: AuthService.currentUser()?.uid ?? '',
                          targetUserId: donor.uid,
                          targetUserName: donor.name,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat, color: Colors.white),
                  label: const Text(
                    "تواصل مع المتبرع",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 25, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
