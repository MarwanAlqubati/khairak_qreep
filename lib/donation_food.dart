import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/Services/charity_service.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:flutter/material.dart';
import 'beneficiary_page.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';

class DonationFoodPage extends StatefulWidget {
  const DonationFoodPage({super.key});

  @override
  State<DonationFoodPage> createState() => _DonationFoodPageState();
}

class _DonationFoodPageState extends State<DonationFoodPage> {
  bool showRequestNumber = false;
  bool showRequestStatus = false;
  String? latestRequestNumber;
  String? needid; // متغير لتخزين قيمة needid
  bool isLoading = true; // متغير لتحديد حالة التحميل

  @override
  void initState() {
    super.initState();
    _fetchNeedId();
  }

  // دالة لجلب needid
  Future<void> _fetchNeedId() async {
    // await CharityService.seedDefaultCampaigns();
    final currentUser = AuthService.currentUser();
    if (currentUser != null) {
      setState(() {
        isLoading = true; // بدء التحميل
      });

      // الحصول على needid من بيانات المستخدم
      needid = currentUser.uid; // أو استخدم الخاصية المناسبة

      await Future.delayed(Duration(seconds: 1)); // محاكاة تحميل البيانات

      setState(() {
        isLoading = false; // الانتهاء من التحميل
      });
    } else {
      setState(() {
        isLoading = false; // الانتهاء من التحميل في حالة عدم وجود مستخدم
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // عرض مؤشر التحميل
          : Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.teal.shade50],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
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
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            label: const Text(
                              "رجوع",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                    const Icon(Icons.volunteer_activism,
                        color: Colors.teal, size: 90),
                    const SizedBox(height: 25),
                    const Text(
                      "طلب تبرع غذائي",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 30,
                      runSpacing: 25,
                      alignment: WrapAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true; // بدء التحميل
                            });

                            final latestRequest = await RequestsService
                                .getLatestRequestByCategoryAndNeedId(
                                    'الطعام', needid!);

                            if (latestRequest != null) {
                              setState(() {
                                latestRequestNumber = latestRequest.reqid;
                                showRequestNumber = true;
                                isLoading = false; // الانتهاء من التحميل
                              });
                            } else {
                              setState(() {
                                latestRequestNumber = "لا توجد طلبات سابقة";
                                showRequestNumber = true;
                                isLoading = false; // الانتهاء من التحميل
                              });
                            }

                            // إخفاء الرسالة بعد 5 ثوانٍ
                            await Future.delayed(Duration(seconds: 5));
                            setState(() {
                              showRequestNumber = false;
                            });
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.receipt_long,
                                      size: 65, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(
                                    "رقم الطلب",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              isLoading = true; // بدء التحميل
                            });

                            String reqid =
                                await RequestsService.generateUniqueReqId();

                            final request = AppRequest(
                              reqid: reqid,
                              needid: needid!,
                              description: 'طلب تبرع غذائي',
                              category: 'الطعام',
                            );
                            await RequestsService.addRequest(request);
                            setState(() {
                              showRequestStatus = true;
                              isLoading = false; // الانتهاء من التحميل
                            });

                            // إخفاء الرسالة بعد 5 ثوانٍ
                            await Future.delayed(Duration(seconds: 5));
                            setState(() {
                              showRequestStatus = false;
                            });
                          },
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              width: 150,
                              height: 150,
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.fastfood,
                                      size: 65, color: Colors.grey),
                                  SizedBox(height: 10),
                                  Text(
                                    "تقديم طلب",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    if (showRequestNumber)
                      _buildInfoCard("رقم الطلب: ${latestRequestNumber ?? ''}"),
                    if (showRequestStatus)
                      _buildInfoCard("✅ تم تقديم طلب تبرع غذائي بنجاح"),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 6),
      child: Card(
        color: Colors.teal.shade50,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
