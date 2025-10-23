import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';
import 'package:exakhairak_qreep/models/app_user.dart';

class RequestWithDonor {
  final AppRequest request;
  final AppUser? donor; // ممكن تكون null لو ما فيه متبرع

  RequestWithDonor({required this.request, this.donor});
}

class RequestsService {
  static final CollectionReference<Map<String, dynamic>> _requests =
      FirebaseFirestore.instance.collection('requests');
  static final _users = FirebaseFirestore.instance.collection('users');

  /// توليد رقم طلب فريد تصاعدي
  static Future<String> generateUniqueReqId() async {
    try {
      // جلب جميع الطلبات وترتيبها حسب reqid
      final snapshot =
          await _requests.orderBy('reqid', descending: true).limit(1).get();

      // إذا لم توجد طلبات، يبدأ من 1
      int nextId = 1;
      if (snapshot.docs.isNotEmpty) {
        // الحصول على أعلى reqid الحالي
        final highestReqId =
            int.tryParse(snapshot.docs.first.data()['reqid'] ?? '0') ?? 0;
        nextId = highestReqId + 1; // زيادة 1 للحصول على الرقم التالي
      }

      return nextId
          .toString()
          .padLeft(6, '0'); // تحويل الرقم إلى سلسلة مع إضافة أصفار على اليسار
    } catch (e) {
      print("Error generating unique reqid: $e");
      return '000001'; // القيمة الافتراضية في حالة الخطأ
    }
  }

  /// إضافة طلب جديد
  static Future<void> addRequest(AppRequest request) async {
    try {
      await _requests.add(request.toMap());
      print("Request added successfully.");
    } catch (e) {
      print("Error adding request: $e");
    }
  }

  /// جلب جميع الطلبات بناءً على needid مع بيانات المتبرع (إن وُجد)
  static Future<List<RequestWithDonor>> getRequestsByNeedId(
      String needid) async {
    try {
      final snapshot = await _requests.where('needid', isEqualTo: needid).get();

      final results = <RequestWithDonor>[];

      for (var doc in snapshot.docs) {
        final request = AppRequest.fromMap(doc.id, doc.data());
        AppUser? donor;

        if (request.donorid != null && request.donorid!.isNotEmpty) {
          final donorSnapshot = await _users.doc(request.donorid).get();

          print("-------------");
          print(request.donorid);
          print(donorSnapshot.data());
          print(donorSnapshot);
          if (donorSnapshot != null) {
            donor = AppUser.fromMap(request.donorid!, donorSnapshot.data()!);
          }
        }

        results.add(RequestWithDonor(request: request, donor: donor));
      }

      return results;
    } catch (e) {
      print("Error fetching requests with donor data: $e");
      return [];
    }
  }

  static Future<AppRequest?> getLatestRequestByCategoryAndNeedId(
      String category, String needid) async {
    try {
      final snapshot = await _requests
          .where('category', isEqualTo: category)
          .where('needid', isEqualTo: needid)
          .where('satats', isEqualTo: '0')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return AppRequest.fromMap(
            snapshot.docs.first.id, snapshot.docs.first.data());
      }
      return null; // لا توجد طلبات
    } catch (e) {
      print("Error fetching latest request: $e");
      return null;
    }
  }

  /// حذف طلب بناءً على reqid
  static Future<void> deleteRequest(String reqid) async {
    try {
      final snapshot = await _requests.where('reqid', isEqualTo: reqid).get();
      if (snapshot.docs.isNotEmpty) {
        for (var doc in snapshot.docs) {
          await _requests.doc(doc.id).delete();
        }
        print("Request with reqid $reqid deleted successfully.");
      } else {
        print("No request found with reqid $reqid.");
      }
    } catch (e) {
      print("Error deleting request: $e");
    }
  }
}
