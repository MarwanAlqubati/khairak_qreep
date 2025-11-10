import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';

/// بطاقة الهيدر (يمكن إعادة استخدامها في صفحات المتبرع)
Widget donorHeaderCard({
  required String donorEmail,
  required VoidCallback onRefresh,
  double avatarRadius = 28,
}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.volunteer_activism,
                color: Colors.teal, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(donorEmail,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, color: Colors.teal)),
        ],
      ),
    ),
  );
}

/// عنصر بطاقة طلب واحد في القائمة
Widget requestItemCard({
  required AppRequest request,
  required VoidCallback onTap,
  bool selected = false,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: selected ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.category,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('رقم الطلب: ${request.reqid}',
                        style: TextStyle(color: Colors.grey.shade700)),
                    if (request.description != null &&
                        request.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(request.description!,
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                    ]
                  ]),
            ),
            if (selected) Icon(Icons.check_circle, color: Colors.teal),
          ],
        ),
      ),
    ),
  );
}

/// قائمة الطلبات القابلة لإعادة الاستخدام
Widget requestListView({
  required List<AppRequest> requests,
  required String? selectedReqId,
  required ValueChanged<AppRequest> onSelect,
}) {
  return requests.isEmpty
      ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('لا توجد طلبات متاحة',
              style: TextStyle(color: Colors.grey.shade600)),
        )
      : ListView.separated(
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final r = requests[idx];
            return requestItemCard(
              request: r,
              selected: selectedReqId == r.reqid,
              onTap: () => onSelect(r),
            );
          },
        );
}

/// صندوق إيصال التبرع المشترك (BottomSheet)
Future<void> showDonationReceiptBottomSheet({
  required BuildContext context,
  required String donationNumber,
  required AppRequest req,
  required String description,
  double? amount,
  VoidCallback? onDone,
}) {
  final now = DateFormat('yyyy-MM-dd').format(DateTime.now());
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              const Icon(Icons.receipt_long, size: 26, color: Colors.teal),
              const SizedBox(width: 8),
              Text('إيصال تبرع',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700)),
            ]),
            const SizedBox(height: 12),
            Text('رقم التبرع: $donationNumber',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('الطلب: ${req.category} • رقم ${req.reqid}'),
            const SizedBox(height: 6),
            if (amount != null)
              Text('المبلغ: ${amount.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text('الحالة: قيد التنفيذ'),
            const SizedBox(height: 6),
            Text('الوقت: $now'),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('ملاحظة: $description'),
            ],
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                if (onDone != null) onDone();
              },
              icon: const Icon(Icons.check),
              label: const Text('حسناً، فهمت'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ]),
    ),
  );
}

/// نافذة تأكيد عامة يمكن إعادة استخدامها
Future<void> showConfirmDialog({
  required BuildContext context,
  required String title,
  required Widget content,
  required VoidCallback onConfirm,
  String confirmText = 'تأكيد',
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: content,
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            onConfirm();
          },
          child: Text(confirmText),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
        )
      ],
    ),
  );
}
