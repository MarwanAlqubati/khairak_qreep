import 'package:exakhairak_qreep/Services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:exakhairak_qreep/models/app_Charity.dart';
import 'package:exakhairak_qreep/Services/charity_service.dart';

class AddCampaignPage extends StatefulWidget {
  const AddCampaignPage({super.key});

  @override
  State<AddCampaignPage> createState() => _AddCampaignPageState();
}

class _AddCampaignPageState extends State<AddCampaignPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _charityNameController = TextEditingController();
  final List<IconData> _availableIcons = [
    Icons.school,
    Icons.ac_unit,
    Icons.fastfood,
    Icons.family_restroom,
    Icons.volunteer_activism,
    Icons.local_hospital,
    Icons.handshake,
    Icons.favorite,
    Icons.campaign,
  ];
  IconData? _selectedIcon;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى اختيار أيقونة للحملة"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final currentUser = AuthService.currentUser();
    final userid = currentUser!.uid;
    setState(() => _isSaving = true);

    final campaign = AppCharity(
      userid: userid,
      titlle: _titleController.text.trim(),
      iconName: _selectedIcon.toString(),
      description: _descriptionController.text.trim(),
      charityname: _charityNameController.text.trim(),
      datecharity: '',
      satats: '1',
    );

    try {
      await CharityService.addCampaign(campaign);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ الحملة بنجاح ✅"),
            backgroundColor: Colors.teal,
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        _charityNameController.clear();
        setState(() => _selectedIcon = null);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ أثناء الحفظ: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _charityNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // شريط علوي
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      label: const Text("رجوع",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                    const Text(
                      "إضافة حملة",
                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        // عنوان الحملة
                        _buildTextField(
                            controller: _titleController,
                            label: "عنوان الحملة"),
                        const SizedBox(height: 15),

                        // وصف الحملة
                        _buildTextField(
                          controller: _descriptionController,
                          label: "وصف الحملة",
                          maxLines: 4,
                        ),
                        const SizedBox(height: 15),

                        // اسم الجمعية
                        _buildTextField(
                            controller: _charityNameController,
                            label: "اسم الجمعية"),
                        const SizedBox(height: 20),

                        // اختيار الأيقونة
                        const Text(
                          "اختر أيقونة الحملة:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableIcons.map((icon) {
                            final selected = _selectedIcon == icon;
                            return ChoiceChip(
                              label: Icon(icon,
                                  color:
                                      selected ? Colors.white : Colors.black54),
                              selected: selected,
                              selectedColor: Colors.teal,
                              padding: const EdgeInsets.all(8),
                              onSelected: (sel) {
                                setState(() {
                                  _selectedIcon = sel ? icon : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // زر حفظ الحملة
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            "حفظ الحملة",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لبناء TextField مع تنسيق موحد
  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.teal)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      ),
      validator: (v) =>
          v == null || v.trim().isEmpty ? "يرجى إدخال $label" : null,
    );
  }
}
