import 'package:flutter/material.dart';
import 'beneficiary_page.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/Services/request_service.dart';
import 'package:exakhairak_qreep/models/app_Request.dart';

class DonationClothesPage extends StatefulWidget {
  const DonationClothesPage({super.key});

  @override
  State<DonationClothesPage> createState() => _DonationClothesPageState();
}

class _DonationClothesPageState extends State<DonationClothesPage> {
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
    final currentUser = AuthService.currentUser();
    if (currentUser != null) {
      // إذا أردت محاكاة تحميل أطول يمكن زيادة التأخير، لكن هنا بسيط
      setStateIfMounted(() {
        isLoading = true;
      });

      // استخدام uid كمثال لneedid — عدّل لو لديك طريقة أخرى
      needid = currentUser.uid;

      await Future.delayed(const Duration(milliseconds: 500)); // محاكاة بسيطة

      setStateIfMounted(() {
        isLoading = false;
      });
    } else {
      setStateIfMounted(() {
        isLoading = false;
      });
    }
  }

  // حزمة حماية: تستدعي setState فقط لو الـ widget لا يزال مركباً (mounted)
  void setStateIfMounted(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                      "طلب تبرع ملابس",
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
                        // زر عرض رقم الطلب الأخير لفئة الملابس
                        GestureDetector(
                          onTap: () async {
                            setStateIfMounted(() {
                              isLoading = true;
                            });

                            if (needid == null) {
                              setStateIfMounted(() {
                                latestRequestNumber =
                                    "لم يتم التعرف على المستخدم";
                                showRequestNumber = true;
                                isLoading = false;
                              });

                              // إخفاء بعد 5 ثواني
                              await Future.delayed(const Duration(seconds: 5));
                              setStateIfMounted(() {
                                showRequestNumber = false;
                              });
                              return;
                            }

                            try {
                              final latestRequest = await RequestsService
                                  .getLatestRequestByCategoryAndNeedId(
                                      'الملابس', needid!);

                              setStateIfMounted(() {
                                if (latestRequest != null) {
                                  latestRequestNumber = latestRequest.reqid;
                                } else {
                                  latestRequestNumber = "لا توجد طلبات سابقة";
                                }
                                showRequestNumber = true;
                                isLoading = false;
                              });
                            } catch (e) {
                              setStateIfMounted(() {
                                latestRequestNumber = "حدث خطأ أثناء التحميل";
                                showRequestNumber = true;
                                isLoading = false;
                              });
                            }

                            // إخفاء الرسالة بعد 5 ثوانٍ
                            await Future.delayed(const Duration(seconds: 5));
                            setStateIfMounted(() {
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

                        // زر تقديم طلب تبرع ملابس
                        GestureDetector(
                          onTap: () async {
                            setStateIfMounted(() {
                              isLoading = true;
                            });

                            if (needid == null) {
                              setStateIfMounted(() {
                                showRequestStatus = true;
                                latestRequestNumber =
                                    "لم يتم التعرف على المستخدم";
                                isLoading = false;
                              });

                              await Future.delayed(const Duration(seconds: 5));
                              setStateIfMounted(() {
                                showRequestStatus = false;
                              });
                              return;
                            }

                            try {
                              String reqid =
                                  await RequestsService.generateUniqueReqId();

                              final request = AppRequest(
                                reqid: reqid,
                                needid: needid!,
                                description: 'طلب تبرع ملابس',
                                category: 'الملابس',
                              );

                              await RequestsService.addRequest(request);

                              setStateIfMounted(() {
                                showRequestStatus = true;
                                isLoading = false;
                              });
                            } catch (e) {
                              setStateIfMounted(() {
                                showRequestStatus = true;
                                latestRequestNumber = "فشل إرسال الطلب";
                                isLoading = false;
                              });
                            }

                            // إخفاء الرسالة بعد 5 ثوانٍ
                            await Future.delayed(const Duration(seconds: 5));
                            setStateIfMounted(() {
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
                                  Icon(Icons.checkroom,
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
                      _buildInfoCard("✅ تم تقديم طلب تبرع ملابس بنجاح"),
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
