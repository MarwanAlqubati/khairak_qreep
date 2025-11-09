import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:exakhairak_qreep/models/app_user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = true;
  bool _isSaving = false;

  AppUser? _appUser;

  // Controllers
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _regionCtrl;
  late TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _dobCtrl = TextEditingController();
    _regionCtrl = TextEditingController();
    _addressCtrl = TextEditingController();

    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() => _isLoading = true);
    final user = AuthService.currentUser();
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final doc = await AuthService.getUserDoc(user.uid);
      if (doc.exists) {
        _appUser = AppUser.fromDocument(doc);
        _nameCtrl.text = _appUser?.name ?? '';
        _emailCtrl.text = _appUser?.email ?? user.email ?? '';
        _phoneCtrl.text = _appUser?.phone ?? '';
        _dobCtrl.text = _appUser?.dob ?? '';
        _regionCtrl.text = _appUser?.region ?? '';
        _addressCtrl.text = _appUser?.address ?? '';
      }
    } catch (e) {
      print('load user error: $e');
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _regionCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    final user = AuthService.currentUser();
    if (user == null) return;

    setState(() => _isSaving = true);

    final data = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'dob': _dobCtrl.text.trim(),
      'region': _regionCtrl.text.trim(),
      'address': _addressCtrl.text.trim(),
      // لا نعدل البريد هنا (تعديله يتطلب إعادة مصادقة وطرق إضافية)
    };

    final ok = await AuthService.updateUserData(user.uid, data);

    setState(() => _isSaving = false);

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('تم حفظ بياناتك بنجاح ✓'),
        backgroundColor: Colors.green,
      ));
      await _loadCurrentUser(); // تحديث الواجهة بالبيانات الجديدة
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('حدث خطأ أثناء حفظ البيانات. حاول مرة أخرى.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final _currentCtrl = TextEditingController();
    final _newCtrl = TextEditingController();
    final _confirmCtrl = TextEditingController();
    final _pwFormKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تغيير كلمة السر'),
        content: Form(
          key: _pwFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _currentCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'كلمة السر الحالية'),
                validator: (v) => (v == null || v.trim().length < 6)
                    ? 'أدخل كلمة السر الحالية'
                    : null,
              ),
              TextFormField(
                controller: _newCtrl,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'كلمة السر الجديدة'),
                validator: (v) => (v == null || v.trim().length < 6)
                    ? 'كلمة السر يجب أن تكون 6 أحرف على الأقل'
                    : null,
              ),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة السر'),
                validator: (v) =>
                    v != _newCtrl.text ? 'تأكيد كلمة السر غير مطابق' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (!_pwFormKey.currentState!.validate()) return;

              // محاولة تغيير كلمة السر
              Navigator.pop(ctx); // أغلق الديالوج أولاً
              final loading = showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) =>
                    const Center(child: CircularProgressIndicator()),
              );

              final result = await AuthService.changePassword(
                  _currentCtrl.text.trim(), _newCtrl.text.trim());

              Navigator.pop(context); // اغلق ال loading

              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('تم تغيير كلمة السر بنجاح.'),
                  backgroundColor: Colors.green,
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('فشل تغيير كلمة السر. تأكد من كلمة السر الحالية.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
  }

  Future<void> _pickDob() async {
    DateTime initial = DateTime.now().subtract(const Duration(days: 365 * 20));
    if (_dobCtrl.text.isNotEmpty) {
      try {
        initial = DateFormat('yyyy-MM-dd').parse(_dobCtrl.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _dobCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والملف الشخصي'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCurrentUser,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.teal.shade100,
                            child: Text(
                              (_appUser?.name.isNotEmpty ?? false)
                                  ? _appUser!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 28, color: Colors.teal),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_appUser?.name ?? 'غير محدد',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(_appUser?.email ?? '',
                                    style: const TextStyle(color: Colors.grey)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _showChangePasswordDialog,
                                      icon: const Icon(Icons.lock_outline),
                                      label: const Text('تغيير كلمة السر'),
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.orange.shade700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'الاسم الكامل',
                              prefixIcon: Icon(Icons.person)),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'الاسم مطلوب'
                              : null,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailCtrl,
                          enabled: false, // تعديل البريد يحتاج عملية منفصلة
                          decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              prefixIcon: Icon(Icons.email)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneCtrl,
                          decoration: const InputDecoration(
                              labelText: 'رقم الجوال',
                              prefixIcon: Icon(Icons.phone)),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _dobCtrl,
                          readOnly: true,
                          decoration: const InputDecoration(
                              labelText: 'تاريخ الميلاد',
                              prefixIcon: Icon(Icons.cake)),
                          onTap: _pickDob,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _regionCtrl,
                          decoration: const InputDecoration(
                              labelText: 'المنطقة/المدينة',
                              prefixIcon: Icon(Icons.location_city)),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration: const InputDecoration(
                              labelText: 'العنوان',
                              prefixIcon: Icon(Icons.home)),
                          minLines: 1,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _isSaving ? null : _saveProfile,
                            icon: _isSaving
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.save),
                            label: const Text('حفظ التغييرات'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
