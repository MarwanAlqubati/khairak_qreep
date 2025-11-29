import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

enum ResetStage {
  enterEmail,
  verifyId,
  codeSent,
  enterCode,
  resetPassword,
  done
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  ResetStage _stage = ResetStage.enterEmail;
  String errorMessage = "";
  bool isLoading = false;

  AppUser? foundUser;
  String? lastSentMessage = "";

  void clearError() {
    if (errorMessage.isNotEmpty) setState(() => errorMessage = "");
  }

  // البحث عن المستخدم بالإيميل (كما لديك)
  Future<void> _onSubmitEmail() async {
    if (emailController.text.trim().isEmpty) {
      setState(() => errorMessage = "الإيميل مطلوب");
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    // try {
    //   final u =
    //       await AuthService.searchUserByEmail(emailController.text.trim());
    //   if (u == null) {
    //     setState(() {
    //       errorMessage = "لا يوجد مستخدم مسجل بهذا الإيميل.";
    //       isLoading = false;
    //     });
    //     return;
    //   }
    //   setState(() {
    //     foundUser = u;
    //     _stage = ResetStage.verifyId;
    //     isLoading = false;
    //   });
    // } catch (e) {
    //   setState(() {
    //     errorMessage = "حدث خطأ أثناء التحقق. حاول مرة أخرى.";
    //     isLoading = false;
    //   });
    // }
  }

  // التحقق من رقم الهوية ثم طلب إرسال رمز (بدل الرابط)
  Future<void> _onVerifyIdAndSendCode() async {
    if (idController.text.trim().isEmpty) {
      setState(() => errorMessage = "أدخل رقم الهوية.");
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    final inputId = idController.text.trim().replaceAll(RegExp(r'\s+'), '');
    final storedId =
        (foundUser?.nationalId ?? '').trim().replaceAll(RegExp(r'\s+'), '');

    if (storedId.isEmpty) {
      setState(() {
        errorMessage = "الحساب لا يحتوي على رقم هوية مسجّل. اتصل بالدعم.";
        isLoading = false;
      });
      return;
    }

    if (inputId != storedId) {
      setState(() {
        errorMessage = "رقم الهوية غير مطابق لسجلاتنا.";
        isLoading = false;
      });
      return;
    }

    // هوية مطابقة — نطلب من الخادوم ارسال رمز
    // try {
    //   await AuthService.requestPasswordResetCode(foundUser!.email);
    //   setState(() {
    //     lastSentMessage =
    //         "تم إرسال رمز تحقق إلى البريد المسجل (تحقق من صندوق الوارد والسبام).";
    //     _stage = ResetStage.enterCode;
    //     isLoading = false;
    //   });
    // } catch (e) {
    //   setState(() {
    //     errorMessage = "فشل إرسال رمز التحقق. حاول لاحقًا.";
    //     isLoading = false;
    //   });
    // }
  }

  // التحقق من صحة الرمز (فقط تحقق)
  Future<void> _onVerifyCode() async {
    if (codeController.text.trim().isEmpty) {
      setState(() => errorMessage = "أدخل رمز التحقق.");
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    // try {
    //   final ok = await AuthService.verifyResetCode(
    //       foundUser!.email, codeController.text.trim());
    //   if (ok) {
    //     setState(() {
    //       _stage = ResetStage.resetPassword;
    //       isLoading = false;
    //     });
    //   } else {
    //     setState(() {
    //       errorMessage = "رمز التحقق غير صحيح أو منتهي الصلاحية.";
    //       isLoading = false;
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     errorMessage = "حدث خطأ أثناء التحقق من الرمز.";
    //     isLoading = false;
    //   });
    // }
  }

  // ارسال الرمز + كلمة المرور الجديدة للخادوم لينفذ التغيير (Admin)
  Future<void> _onConfirmReset() async {
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      setState(() => errorMessage = "أدخل كلمة المرور وتأكيدها.");
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() => errorMessage = "كلمة المرور غير متطابقة.");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    // try {
    //   final success = await AuthService.confirmPasswordReset(
    //     foundUser!.email,
    //     codeController.text.trim(),
    //     newPasswordController.text,
    //   );
    //   if (success) {
    //     setState(() {
    //       _stage = ResetStage.done;
    //       isLoading = false;
    //     });
    //   } else {
    //     setState(() {
    //       errorMessage =
    //           "فشل إعادة تعيين كلمة المرور. تأكد من الرمز وحاول مجددًا.";
    //       isLoading = false;
    //     });
    //   }
    // } catch (e) {
    //   setState(() {
    //     errorMessage = "حدث خطأ أثناء إعادة التعيين.";
    //     isLoading = false;
    //   });
    // }
  }

  Widget _buildEnterEmail() {
    /* مشابه لكودك السابق */
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "أدخل البريد الإلكتروني المسجل",
            prefixIcon: Icon(Icons.email),
          ),
          onChanged: (_) => clearError(),
        ),
        const SizedBox(height: 20),
        if (errorMessage.isNotEmpty)
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: isLoading ? null : _onSubmitEmail,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("تحقق من البريد"),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyId() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 6),
        Text("تم العثور على حساب مرتبط بهذا الإيميل:"),
        const SizedBox(height: 8),
        Text(foundUser!.email,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        TextFormField(
          controller: idController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "أدخل رقم الهوية للتحقق",
            prefixIcon: Icon(Icons.credit_card),
          ),
          onChanged: (_) => clearError(),
        ),
        const SizedBox(height: 12),
        if (errorMessage.isNotEmpty)
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            onPressed: isLoading ? null : _onVerifyIdAndSendCode,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("تحقق وأرسل رمز التحقق"),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  setState(() {
                    _stage = ResetStage.enterEmail;
                    foundUser = null;
                    idController.clear();
                    errorMessage = "";
                  });
                },
          child: const Text("تغيير الإيميل"),
        ),
      ],
    );
  }

  Widget _buildEnterCode() {
    return Column(
      children: [
        if (lastSentMessage != null)
          Text(lastSentMessage!, style: const TextStyle(color: Colors.green)),
        const SizedBox(height: 12),
        TextFormField(
          controller: codeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: "أدخل رمز التحقق", prefixIcon: Icon(Icons.vpn_key)),
          onChanged: (_) => clearError(),
        ),
        const SizedBox(height: 12),
        if (errorMessage.isNotEmpty)
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onVerifyCode,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("تحقق من الرمز"),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  // اعادة ارسال الرمز (اختياري): نعيد طلب send code
                  _onVerifyIdAndSendCode();
                },
          child: const Text("إعادة إرسال الرمز"),
        )
      ],
    );
  }

  Widget _buildResetPassword() {
    return Column(
      children: [
        TextFormField(
          controller: newPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: "أدخل كلمة المرور الجديدة",
              prefixIcon: Icon(Icons.lock)),
          onChanged: (_) => clearError(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: const InputDecoration(
              labelText: "تأكيد كلمة المرور",
              prefixIcon: Icon(Icons.lock_outline)),
          onChanged: (_) => clearError(),
        ),
        const SizedBox(height: 12),
        if (errorMessage.isNotEmpty)
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _onConfirmReset,
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("تحديث كلمة المرور"),
          ),
        ),
      ],
    );
  }

  Widget _buildDone() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        const Text(
          "تمت إعادة تعيين كلمة المرور بنجاح.\nيمكنك الآن تسجيل الدخول بالكلمة الجديدة.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text("العودة لتسجيل الدخول"),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_stage) {
      case ResetStage.enterEmail:
        content = _buildEnterEmail();
        break;
      case ResetStage.verifyId:
        content = _buildVerifyId();
        break;
      case ResetStage.enterCode:
        content = _buildEnterCode();
        break;
      case ResetStage.resetPassword:
        content = _buildResetPassword();
        break;
      case ResetStage.done:
        content = _buildDone();
        break;
      default:
        content = _buildEnterEmail();
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.teal.shade100]),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Align(
                        alignment: Alignment.topLeft,
                        child: Icon(Icons.volunteer_activism,
                            color: Colors.teal, size: 80)),
                    const SizedBox(height: 10),
                    const Text("استعادة كلمة المرور",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber)),
                    const SizedBox(height: 30),
                    Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(key: _formKey, child: content),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (_stage != ResetStage.done)
                      TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          child: const Text("العودة لتسجيل الدخول")),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
